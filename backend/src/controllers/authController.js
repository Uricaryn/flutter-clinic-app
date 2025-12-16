import User from '../models/User.js';
import { generateTokens, generateAccessToken, verifyAccessToken } from '../config/auth.js';
import { asyncHandler } from '../middleware/errorHandler.js';
import { blacklistToken } from '../utils/tokenBlacklist.js';
import { sendVerificationEmail, sendPasswordResetEmail, sendWelcomeEmail } from '../utils/emailService.js';
import crypto from 'crypto';

// Register a new user
export const register = asyncHandler(async (req, res) => {
  const { email, password, fullName, phone, role, clinicId } = req.body;

  // Check if user already exists
  const existingUser = await User.findByEmail(email);
  if (existingUser) {
    return res.status(409).json({
      success: false,
      message: 'User with this email already exists',
    });
  }

  // Create new user
  // Convert empty string to null for UUID fields
  const user = await User.create({
    email,
    password,
    fullName,
    phone,
    role: role || 'user',
    clinicId: clinicId && clinicId.trim() !== '' ? clinicId : null,
  });

  // Generate tokens
  const { accessToken, refreshToken } = generateTokens(user);

  // Send verification email (non-blocking - don't fail registration if email fails)
  // Only attempt if SMTP is configured
  if (process.env.SMTP_PASSWORD && process.env.SMTP_PASSWORD !== 'DISABLED_FOR_NOW') {
    try {
      // Generate verification token
      const verificationToken = crypto.randomBytes(32).toString('hex');
      const verificationTokenExpiry = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

      // Save verification token to user
      await User.update(user.id, {
        verification_token: verificationToken,
        verification_token_expiry: verificationTokenExpiry,
      });

      // Send email asynchronously
      sendVerificationEmail(user.email, verificationToken, user.full_name)
        .then(() => console.log(`✅ Verification email sent to ${user.email}`))
        .catch((err) => console.error(`❌ Failed to send verification email: ${err.message}`));
    } catch (emailError) {
      // Log error but don't fail registration
      console.error('Email sending error:', emailError.message);
    }
  } else {
    console.log('⚠️  Email sending is disabled - configure SMTP in .env to enable');
  }

  res.status(201).json({
    success: true,
    message: 'User registered successfully',
    data: {
      user: {
        id: user.id,
        email: user.email,
        fullName: user.full_name,
        phone: user.phone,
        role: user.role,
        clinicId: user.clinic_id,
        emailVerified: user.email_verified,
      },
      accessToken,
      refreshToken,
    },
  });
});

// Login user
export const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  // Find user by email
  const user = await User.findByEmail(email);
  if (!user) {
    return res.status(401).json({
      success: false,
      message: 'Invalid email or password',
    });
  }

  // Check if user is active
  if (!user.is_active) {
    return res.status(403).json({
      success: false,
      message: 'Account is deactivated. Please contact support.',
    });
  }

  // Verify password
  const isPasswordValid = await User.verifyPassword(password, user.password_hash);
  if (!isPasswordValid) {
    return res.status(401).json({
      success: false,
      message: 'Invalid email or password',
    });
  }

  // Update last login
  await User.updateLastLogin(user.id);

  // Generate tokens
  const { accessToken, refreshToken } = generateTokens(user);

  res.status(200).json({
    success: true,
    message: 'Login successful',
    data: {
      user: {
        id: user.id,
        email: user.email,
        fullName: user.full_name,
        phone: user.phone,
        avatar: user.avatar,
        role: user.role,
        clinicId: user.clinic_id,
        emailVerified: user.email_verified,
      },
      accessToken,
      refreshToken,
    },
  });
});

// Logout user
export const logout = asyncHandler(async (req, res) => {
  const userId = req.user.userId;
  const token = req.token; // Token attached by authenticate middleware

  // Update last logout
  await User.updateLastLogout(userId);

  // Blacklist the token to prevent reuse
  // Calculate remaining time until token expires
  try {
    const decoded = verifyAccessToken(token);
    const expiresIn = decoded.exp - Math.floor(Date.now() / 1000);
    if (expiresIn > 0) {
      blacklistToken(token, expiresIn);
    }
  } catch (error) {
    // Token already expired or invalid, no need to blacklist
  }

  res.status(200).json({
    success: true,
    message: 'Logout successful',
  });
});

// Get current user
export const getCurrentUser = asyncHandler(async (req, res) => {
  const userId = req.user.userId;

  const user = await User.findById(userId);
  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'User not found',
    });
  }

  res.status(200).json({
    success: true,
    data: {
      id: user.id,
      email: user.email,
      fullName: user.full_name,
      phone: user.phone,
      avatar: user.avatar,
      role: user.role,
      clinicId: user.clinic_id,
      emailVerified: user.email_verified,
      createdAt: user.created_at,
      lastLogin: user.last_login,
    },
  });
});

// Refresh token
export const refreshToken = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    return res.status(400).json({
      success: false,
      message: 'Refresh token is required',
    });
  }

  try {
    const { verifyRefreshToken } = await import('../config/auth.js');
    const decoded = verifyRefreshToken(refreshToken);

    // Get user
    const user = await User.findById(decoded.userId);
    if (!user || !user.is_active) {
      return res.status(401).json({
        success: false,
        message: 'Invalid refresh token',
      });
    }

    // Generate new tokens
    const tokens = generateTokens(user);

    res.status(200).json({
      success: true,
      data: tokens,
    });
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired refresh token',
    });
  }
});

// Request password reset
export const requestPasswordReset = asyncHandler(async (req, res) => {
  const { email } = req.body;

  // Find user by email
  const user = await User.findByEmail(email);
  
  // Always return success to prevent email enumeration attacks
  // Even if user doesn't exist, respond with success
  if (!user) {
    return res.status(200).json({
      success: true,
      message: 'If an account with that email exists, a password reset link has been sent.',
    });
  }

  // Generate reset token
  const resetToken = crypto.randomBytes(32).toString('hex');
  const resetTokenHash = crypto.createHash('sha256').update(resetToken).digest('hex');
  const resetTokenExpiry = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

  // Save reset token to user
  await User.update(user.id, {
    reset_token: resetTokenHash,
    reset_token_expiry: resetTokenExpiry,
  });

  // Send email
  try {
    await sendPasswordResetEmail(email, resetToken, user.full_name);
  } catch (error) {
    console.error('Failed to send password reset email:', error);
    // Don't expose email sending failure to user
  }

  res.status(200).json({
    success: true,
    message: 'If an account with that email exists, a password reset link has been sent.',
  });
});

// Reset password with token
export const resetPassword = asyncHandler(async (req, res) => {
  const { token, newPassword } = req.body;

  if (!token || !newPassword) {
    return res.status(400).json({
      success: false,
      message: 'Token and new password are required',
    });
  }

  // Hash the token to match stored hash
  const resetTokenHash = crypto.createHash('sha256').update(token).digest('hex');

  // Find user with valid reset token
  const user = await User.findByResetToken(resetTokenHash);

  if (!user) {
    return res.status(400).json({
      success: false,
      message: 'Invalid or expired reset token',
    });
  }

  // Update password and clear reset token
  await User.updatePassword(user.id, newPassword);
  await User.update(user.id, {
    reset_token: null,
    reset_token_expiry: null,
  });

  res.status(200).json({
    success: true,
    message: 'Password has been reset successfully. You can now login with your new password.',
  });
});

// Send email verification
export const sendEmailVerification = asyncHandler(async (req, res) => {
  const userId = req.user.userId;

  const user = await User.findById(userId);
  
  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'User not found',
    });
  }

  if (user.email_verified) {
    return res.status(400).json({
      success: false,
      message: 'Email is already verified',
    });
  }

  // Generate verification token
  const verificationToken = crypto.randomBytes(32).toString('hex');
  const verificationTokenHash = crypto.createHash('sha256').update(verificationToken).digest('hex');
  const verificationTokenExpiry = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

  // Save verification token
  await User.update(userId, {
    verification_token: verificationTokenHash,
    verification_token_expiry: verificationTokenExpiry,
  });

  // Send email
  try {
    await sendVerificationEmail(user.email, verificationToken, user.full_name);
    res.status(200).json({
      success: true,
      message: 'Verification email has been sent',
    });
  } catch (error) {
    console.error('Failed to send verification email:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to send verification email. Please try again later.',
    });
  }
});

// Verify email with token
export const verifyEmail = asyncHandler(async (req, res) => {
  const { token } = req.body;

  if (!token) {
    return res.status(400).json({
      success: false,
      message: 'Verification token is required',
    });
  }

  // Hash the token to match stored hash
  const verificationTokenHash = crypto.createHash('sha256').update(token).digest('hex');

  // Find user with valid verification token
  const user = await User.findByVerificationToken(verificationTokenHash);

  if (!user) {
    return res.status(400).json({
      success: false,
      message: 'Invalid or expired verification token',
    });
  }

  // Mark email as verified and clear verification token
  await User.update(user.id, {
    email_verified: true,
    verification_token: null,
    verification_token_expiry: null,
  });

  res.status(200).json({
    success: true,
    message: 'Email verified successfully',
  });
});

// Change password (for authenticated users)
export const changePassword = asyncHandler(async (req, res) => {
  const userId = req.user.userId;
  const { currentPassword, newPassword } = req.body;

  if (!currentPassword || !newPassword) {
    return res.status(400).json({
      success: false,
      message: 'Current password and new password are required',
    });
  }

  // Get user with password hash
  const user = await User.findByEmail(req.user.email);

  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'User not found',
    });
  }

  // Verify current password
  const isPasswordValid = await User.verifyPassword(currentPassword, user.password_hash);

  if (!isPasswordValid) {
    return res.status(401).json({
      success: false,
      message: 'Current password is incorrect',
    });
  }

  // Update password
  await User.updatePassword(userId, newPassword);

  res.status(200).json({
    success: true,
    message: 'Password changed successfully',
  });
});

export default {
  register,
  login,
  logout,
  getCurrentUser,
  refreshToken,
  requestPasswordReset,
  resetPassword,
  sendEmailVerification,
  verifyEmail,
  changePassword,
};

