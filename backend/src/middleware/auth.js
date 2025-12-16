import { verifyAccessToken } from '../config/auth.js';
import { isTokenBlacklisted } from '../utils/tokenBlacklist.js';

// Middleware to verify JWT token
export const authenticate = async (req, res, next) => {
  try {
    // Get token from Authorization header
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'No token provided. Authorization header must be in format: Bearer [token]',
      });
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix

    // Check if token is blacklisted
    if (isTokenBlacklisted(token)) {
      return res.status(401).json({
        success: false,
        message: 'Token has been revoked. Please login again.',
      });
    }

    // Verify token
    const decoded = verifyAccessToken(token);

    // Attach user info to request
    req.user = {
      userId: decoded.userId,
      email: decoded.email,
      role: decoded.role,
      clinicId: decoded.clinicId,
    };

    // Attach token for potential blacklisting on logout
    req.token = token;

    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired token',
      error: error.message,
    });
  }
};

// Middleware to check if user belongs to a clinic
export const requireClinic = (req, res, next) => {
  if (!req.user.clinicId) {
    return res.status(403).json({
      success: false,
      message: 'User does not belong to any clinic',
    });
  }
  next();
};

// Middleware to check user role
export const requireRole = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required',
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Access denied. Required roles: ${roles.join(', ')}`,
      });
    }

    next();
  };
};

// Middleware to check if user can access specific clinic data
export const requireClinicAccess = (req, res, next) => {
  const clinicId = req.params.clinicId || req.body.clinicId || req.query.clinicId;

  if (!clinicId) {
    return res.status(400).json({
      success: false,
      message: 'Clinic ID is required',
    });
  }

  // Admin can access all clinics
  if (req.user.role === 'admin') {
    return next();
  }

  // User must belong to the clinic they're trying to access
  if (req.user.clinicId !== clinicId) {
    return res.status(403).json({
      success: false,
      message: 'Access denied. You do not have permission to access this clinic',
    });
  }

  next();
};

export default {
  authenticate,
  requireClinic,
  requireRole,
  requireClinicAccess,
};
