/**
 * WebSocket Service for Real-time Updates
 * 
 * This service provides real-time updates to clients using WebSockets.
 * It uses PostgreSQL LISTEN/NOTIFY for database change notifications.
 */

import { WebSocket, WebSocketServer } from 'ws';
import jwt from 'jsonwebtoken';
import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pg;

class WebSocketService {
  constructor() {
    this.wss = null;
    this.clients = new Map(); // Map of clinicId -> Set of WebSocket connections
    this.pgPool = null;
    this.notifyClient = null;
  }

  /**
   * Initialize WebSocket server
   * @param {http.Server} server - HTTP server instance
   */
  initialize(server) {
    this.wss = new WebSocketServer({ 
      server,
      path: '/ws'
    });

    // Initialize PostgreSQL connection for LISTEN/NOTIFY
    this.initializePgNotify();

    this.wss.on('connection', (ws, req) => {
      this.handleConnection(ws, req);
    });

    console.log('✅ WebSocket server initialized at /ws');
  }

  /**
   * Initialize PostgreSQL LISTEN/NOTIFY
   */
  async initializePgNotify() {
    try {
      this.pgPool = new Pool({
        connectionString: process.env.DATABASE_URL
      });

      this.notifyClient = await this.pgPool.connect();

      // Listen to database changes
      await this.notifyClient.query('LISTEN clinic_changes');

      this.notifyClient.on('notification', (msg) => {
        try {
          const payload = JSON.parse(msg.payload);
          this.broadcastToClinic(payload.clinicId, {
            type: 'update',
            collection: payload.table,
            action: payload.action,
            data: payload.data
          });
        } catch (err) {
          console.error('Error processing notification:', err);
        }
      });

      console.log('✅ PostgreSQL LISTEN/NOTIFY initialized');
    } catch (err) {
      console.error('❌ Failed to initialize PostgreSQL LISTEN/NOTIFY:', err);
    }
  }

  /**
   * Handle new WebSocket connection
   */
  handleConnection(ws, req) {
    console.log('🔌 New WebSocket connection attempt');

    // Extract token from query string or headers
    const token = this.extractToken(req);

    if (!token) {
      ws.close(1008, 'Authentication required');
      return;
    }

    try {
      // Verify JWT token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      ws.userId = decoded.userId;
      ws.clinicId = decoded.clinicId;
      ws.role = decoded.role;
      ws.isAuthenticated = true;
      ws.subscribedCollections = new Set();

      console.log(`✅ Client authenticated: ${ws.userId} (Clinic: ${ws.clinicId})`);

      // Add client to clinic group
      if (!this.clients.has(ws.clinicId)) {
        this.clients.set(ws.clinicId, new Set());
      }
      this.clients.get(ws.clinicId).add(ws);

      // Send welcome message
      ws.send(JSON.stringify({
        type: 'connected',
        message: 'WebSocket connection established',
        clinicId: ws.clinicId
      }));

      // Handle messages
      ws.on('message', (message) => {
        this.handleMessage(ws, message);
      });

      // Handle disconnect
      ws.on('close', () => {
        this.handleDisconnect(ws);
      });

      // Handle errors
      ws.on('error', (err) => {
        console.error('WebSocket error:', err);
      });

    } catch (err) {
      console.error('❌ Authentication failed:', err.message);
      ws.close(1008, 'Invalid token');
    }
  }

  /**
   * Extract token from request
   */
  extractToken(req) {
    // Try query string first
    const url = new URL(req.url, `http://${req.headers.host}`);
    const queryToken = url.searchParams.get('token');
    if (queryToken) return queryToken;

    // Try Authorization header
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      return authHeader.substring(7);
    }

    return null;
  }

  /**
   * Handle incoming messages from clients
   */
  handleMessage(ws, message) {
    try {
      const data = JSON.parse(message);

      switch (data.type) {
        case 'subscribe':
          this.handleSubscribe(ws, data);
          break;
        case 'unsubscribe':
          this.handleUnsubscribe(ws, data);
          break;
        case 'ping':
          ws.send(JSON.stringify({ type: 'pong' }));
          break;
        default:
          ws.send(JSON.stringify({ 
            type: 'error', 
            message: 'Unknown message type' 
          }));
      }
    } catch (err) {
      console.error('Error handling message:', err);
      ws.send(JSON.stringify({ 
        type: 'error', 
        message: 'Invalid message format' 
      }));
    }
  }

  /**
   * Handle collection subscription
   */
  handleSubscribe(ws, data) {
    const { collection } = data;

    if (!collection) {
      ws.send(JSON.stringify({ 
        type: 'error', 
        message: 'Collection name required' 
      }));
      return;
    }

    const validCollections = [
      'appointments',
      'patients',
      'procedures',
      'stock_items',
      'expenses',
      'operators'
    ];

    if (!validCollections.includes(collection)) {
      ws.send(JSON.stringify({ 
        type: 'error', 
        message: 'Invalid collection name' 
      }));
      return;
    }

    ws.subscribedCollections.add(collection);

    ws.send(JSON.stringify({
      type: 'subscribed',
      collection,
      message: `Subscribed to ${collection} updates`
    }));

    console.log(`📡 Client ${ws.userId} subscribed to ${collection}`);
  }

  /**
   * Handle collection unsubscription
   */
  handleUnsubscribe(ws, data) {
    const { collection } = data;

    if (collection) {
      ws.subscribedCollections.delete(collection);
      ws.send(JSON.stringify({
        type: 'unsubscribed',
        collection,
        message: `Unsubscribed from ${collection} updates`
      }));
    }
  }

  /**
   * Handle client disconnect
   */
  handleDisconnect(ws) {
    console.log(`🔌 Client disconnected: ${ws.userId}`);

    if (ws.clinicId && this.clients.has(ws.clinicId)) {
      const clinicClients = this.clients.get(ws.clinicId);
      clinicClients.delete(ws);

      if (clinicClients.size === 0) {
        this.clients.delete(ws.clinicId);
      }
    }
  }

  /**
   * Broadcast message to all clients in a clinic
   */
  broadcastToClinic(clinicId, message) {
    if (!this.clients.has(clinicId)) return;

    const clinicClients = this.clients.get(clinicId);
    const messageStr = JSON.stringify(message);

    let sentCount = 0;
    clinicClients.forEach(client => {
      // Only send if client is subscribed to this collection
      if (client.readyState === WebSocket.OPEN && 
          (client.subscribedCollections.size === 0 || 
           client.subscribedCollections.has(message.collection))) {
        client.send(messageStr);
        sentCount++;
      }
    });

    if (sentCount > 0) {
      console.log(`📤 Broadcasted ${message.action} on ${message.collection} to ${sentCount} client(s) in clinic ${clinicId}`);
    }
  }

  /**
   * Notify database change (called from controllers)
   */
  async notifyChange(clinicId, table, action, data) {
    try {
      // Broadcast to WebSocket clients
      this.broadcastToClinic(clinicId, {
        type: 'update',
        collection: table,
        action, // 'created', 'updated', 'deleted'
        data
      });

      // Also trigger PostgreSQL NOTIFY for other server instances (if scaled)
      if (this.pgPool) {
        await this.pgPool.query(
          'SELECT pg_notify($1, $2)',
          [
            'clinic_changes',
            JSON.stringify({ clinicId, table, action, data })
          ]
        );
      }
    } catch (err) {
      console.error('Error notifying change:', err);
    }
  }

  /**
   * Get connection stats
   */
  getStats() {
    const stats = {
      totalClients: 0,
      clinics: {}
    };

    this.clients.forEach((clients, clinicId) => {
      stats.clinics[clinicId] = clients.size;
      stats.totalClients += clients.size;
    });

    return stats;
  }

  /**
   * Close all connections and cleanup
   */
  async close() {
    if (this.notifyClient) {
      await this.notifyClient.query('UNLISTEN clinic_changes');
      this.notifyClient.release();
    }

    if (this.pgPool) {
      await this.pgPool.end();
    }

    if (this.wss) {
      this.wss.close();
    }

    console.log('✅ WebSocket service closed');
  }
}

// Singleton instance
const websocketService = new WebSocketService();

export default websocketService;
