import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import http from 'http';
import { testConnection } from './config/database.js';
import { errorHandler, notFoundHandler } from './middleware/errorHandler.js';
import { apiLimiter } from './middleware/rateLimiter.js';
import websocketService from './services/websocketService.js';

// Import routes
import authRoutes from './routes/auth.js';
import appointmentRoutes from './routes/appointments.js';
import patientRoutes from './routes/patients.js';
import clinicRoutes from './routes/clinics.js';
import procedureRoutes from './routes/procedures.js';
import stockRoutes from './routes/stock.js';
import expenseRoutes from './routes/expenses.js';
import operatorRoutes from './routes/operators.js';

// Load environment variables
dotenv.config();

// Create Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet()); // Security headers
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  credentials: true,
}));
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies

// Apply rate limiting to all API routes
app.use('/api/', apiLimiter);

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString(),
    websocket: websocketService.getStats(),
  });
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/appointments', appointmentRoutes);
app.use('/api/patients', patientRoutes);
app.use('/api/clinics', clinicRoutes);
app.use('/api/procedures', procedureRoutes);
app.use('/api/stock', stockRoutes);
app.use('/api/expenses', expenseRoutes);
app.use('/api/operators', operatorRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Clinic App Backend API',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      auth: '/api/auth',
      appointments: '/api/appointments',
      patients: '/api/patients',
      clinics: '/api/clinics',
      procedures: '/api/procedures',
      stock: '/api/stock',
      expenses: '/api/expenses',
      operators: '/api/operators',
    },
  });
});

// 404 handler
app.use(notFoundHandler);

// Error handling middleware (must be last)
app.use(errorHandler);

// Create HTTP server
const server = http.createServer(app);

// Start server
const startServer = async () => {
  try {
    // Test database connection
    console.log('🔌 Testing database connection...');
    const dbConnected = await testConnection();

    if (!dbConnected) {
      console.error('❌ Failed to connect to database. Exiting...');
      process.exit(1);
    }

    // Initialize WebSocket service
    console.log('🔌 Initializing WebSocket service...');
    websocketService.initialize(server);

    // Start listening
    server.listen(PORT, () => {
      console.log('');
      console.log('═══════════════════════════════════════════════════');
      console.log(`🚀 Server is running on port ${PORT}`);
      console.log(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`🌐 API URL: http://localhost:${PORT}`);
      console.log(`🔌 WebSocket: ws://localhost:${PORT}/ws`);
      console.log(`💚 Health check: http://localhost:${PORT}/health`);
      console.log('═══════════════════════════════════════════════════');
      console.log('');
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('❌ Unhandled Promise Rejection:', err);
  process.exit(1);
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('❌ Uncaught Exception:', err);
  process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('👋 SIGTERM signal received: closing servers');
  await websocketService.close();
  server.close(() => {
    process.exit(0);
  });
});

process.on('SIGINT', async () => {
  console.log('👋 SIGINT signal received: closing servers');
  await websocketService.close();
  server.close(() => {
    process.exit(0);
  });
});

// Start the server
startServer();

export default app;
