// Middleware for clinic-specific authorization
// Ensures users can only access data from their own clinic

/**
 * Middleware to validate clinic ID from request and ensure user has access
 * Works with clinicId from params, body, or query
 */
export const validateClinicAccess = (req, res, next) => {
  // Extract clinic ID from various sources
  const clinicId = req.params.clinicId || req.body.clinicId || req.query.clinicId;

  if (!clinicId) {
    return res.status(400).json({
      success: false,
      message: 'Clinic ID is required',
    });
  }

  // Attach clinic ID to request for later use
  req.clinicId = clinicId;

  // Admin can access all clinics
  if (req.user.role === 'admin') {
    return next();
  }

  // User must belong to the clinic they're trying to access
  if (req.user.clinicId !== clinicId) {
    return res.status(403).json({
      success: false,
      message: 'Access denied. You do not have permission to access this clinic\'s data',
    });
  }

  next();
};

/**
 * Middleware to ensure user belongs to a clinic
 * Use this for endpoints that require clinic membership
 */
export const requireClinicMembership = (req, res, next) => {
  if (!req.user.clinicId) {
    return res.status(403).json({
      success: false,
      message: 'Access denied. You must belong to a clinic to access this resource',
    });
  }

  // Attach clinic ID to request for convenience
  req.clinicId = req.user.clinicId;
  next();
};

/**
 * Middleware to ensure user owns or manages the clinic
 * Use this for sensitive operations like clinic settings
 */
export const requireClinicOwnership = async (req, res, next) => {
  const clinicId = req.params.clinicId || req.body.clinicId || req.query.clinicId;

  if (!clinicId) {
    return res.status(400).json({
      success: false,
      message: 'Clinic ID is required',
    });
  }

  // Admin can manage all clinics
  if (req.user.role === 'admin') {
    return next();
  }

  // User must be the owner of the clinic
  if (req.user.clinicId !== clinicId) {
    return res.status(403).json({
      success: false,
      message: 'Access denied. Only clinic owners can perform this action',
    });
  }

  // Check if user has owner/admin role
  if (req.user.role !== 'owner' && req.user.role !== 'admin') {
    return res.status(403).json({
      success: false,
      message: 'Access denied. Only clinic owners or administrators can perform this action',
    });
  }

  next();
};

/**
 * Middleware to validate resource belongs to user's clinic
 * Call this after fetching a resource to verify it belongs to the correct clinic
 * 
 * @param {string} resourceClinicId - The clinic ID from the fetched resource
 */
export const validateResourceClinic = (resourceClinicId) => {
  return (req, res, next) => {
    // Admin can access all
    if (req.user.role === 'admin') {
      return next();
    }

    // Check if resource belongs to user's clinic
    if (resourceClinicId !== req.user.clinicId) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. This resource does not belong to your clinic',
      });
    }

    next();
  };
};

/**
 * Middleware to ensure only specific roles within a clinic can access
 * 
 * @param {string[]} allowedRoles - Array of allowed roles
 */
export const requireClinicRole = (...allowedRoles) => {
  return (req, res, next) => {
    // Admin can do everything
    if (req.user.role === 'admin') {
      return next();
    }

    // Check if user belongs to a clinic
    if (!req.user.clinicId) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. You must belong to a clinic',
      });
    }

    // Check if user has one of the allowed roles
    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Access denied. Required roles: ${allowedRoles.join(', ')}`,
      });
    }

    next();
  };
};

export default {
  validateClinicAccess,
  requireClinicMembership,
  requireClinicOwnership,
  validateResourceClinic,
  requireClinicRole,
};

