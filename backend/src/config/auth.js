import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

// JWT configuration
export const jwtConfig = {
  secret: process.env.JWT_SECRET || 'your-super-secret-jwt-key',
  expiresIn: process.env.JWT_EXPIRATION || '7d',
  refreshSecret: process.env.REFRESH_TOKEN_SECRET || 'your-super-secret-refresh-token-key',
  refreshExpiresIn: process.env.REFRESH_TOKEN_EXPIRATION || '30d',
};

// Generate access token
export const generateAccessToken = (payload) => {
  return jwt.sign(payload, jwtConfig.secret, {
    expiresIn: jwtConfig.expiresIn,
  });
};

// Generate refresh token
export const generateRefreshToken = (payload) => {
  return jwt.sign(payload, jwtConfig.refreshSecret, {
    expiresIn: jwtConfig.refreshExpiresIn,
  });
};

// Verify access token
export const verifyAccessToken = (token) => {
  try {
    return jwt.verify(token, jwtConfig.secret);
  } catch (error) {
    throw new Error('Invalid or expired token');
  }
};

// Verify refresh token
export const verifyRefreshToken = (token) => {
  try {
    return jwt.verify(token, jwtConfig.refreshSecret);
  } catch (error) {
    throw new Error('Invalid or expired refresh token');
  }
};

// Generate both tokens
export const generateTokens = (user) => {
  const payload = {
    userId: user.id,
    email: user.email,
    role: user.role,
    clinicId: user.clinic_id,
  };

  const accessToken = generateAccessToken(payload);
  const refreshToken = generateRefreshToken(payload);

  return { accessToken, refreshToken };
};

export default {
  jwtConfig,
  generateAccessToken,
  generateRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
  generateTokens,
};

