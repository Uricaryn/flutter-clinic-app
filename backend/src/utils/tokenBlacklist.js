// In-memory token blacklist
// In production, use Redis or database for distributed systems
const blacklist = new Set();

/**
 * Add a token to the blacklist
 * @param {string} token - JWT token to blacklist
 * @param {number} expiresIn - Time in seconds until token naturally expires
 */
export const blacklistToken = (token, expiresIn) => {
  blacklist.add(token);

  // Auto-remove from blacklist after token expiration
  // This prevents memory leaks from accumulating expired tokens
  if (expiresIn) {
    setTimeout(() => {
      blacklist.delete(token);
    }, expiresIn * 1000);
  }
};

/**
 * Check if a token is blacklisted
 * @param {string} token - JWT token to check
 * @returns {boolean} True if token is blacklisted
 */
export const isTokenBlacklisted = (token) => {
  return blacklist.has(token);
};

/**
 * Remove a token from blacklist (rarely needed)
 * @param {string} token - JWT token to remove
 */
export const removeFromBlacklist = (token) => {
  return blacklist.delete(token);
};

/**
 * Clear all blacklisted tokens (use with caution)
 */
export const clearBlacklist = () => {
  blacklist.clear();
};

/**
 * Get blacklist size (for monitoring)
 * @returns {number} Number of blacklisted tokens
 */
export const getBlacklistSize = () => {
  return blacklist.size;
};

export default {
  blacklistToken,
  isTokenBlacklisted,
  removeFromBlacklist,
  clearBlacklist,
  getBlacklistSize,
};

