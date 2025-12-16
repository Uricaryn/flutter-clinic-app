import express from 'express';
import { body } from 'express-validator';
import * as authController from '../controllers/authController.js';
import { authenticate } from '../middleware/auth.js';
import validate from '../middleware/validator.js';

const router = express.Router();

// Import rate limiters
import { authLimiter, registerLimiter, passwordResetLimiter } from '../middleware/rateLimiter.js';

// Validation rules
const registerValidation = [
  body('email').isEmail().normalizeEmail().withMessage('Invalid email address'),
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters long')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Password must contain at least one uppercase letter, one lowercase letter, and one number'),
  body('fullName').trim().notEmpty().withMessage('Full name is required'),
  body('role')
    .optional()
    .isIn(['clinic_admin', 'clinic_manager', 'operator', 'doctor', 'patient', 'admin', 'user'])
    .withMessage('Invalid role'),
];

const loginValidation = [
  body('email').isEmail().normalizeEmail().withMessage('Invalid email address'),
  body('password').notEmpty().withMessage('Password is required'),
];

const passwordResetRequestValidation = [
  body('email').isEmail().normalizeEmail().withMessage('Invalid email address'),
];

const passwordResetValidation = [
  body('token').notEmpty().withMessage('Reset token is required'),
  body('newPassword')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters long')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Password must contain at least one uppercase letter, one lowercase letter, and one number'),
];

const changePasswordValidation = [
  body('currentPassword').notEmpty().withMessage('Current password is required'),
  body('newPassword')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters long')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Password must contain at least one uppercase letter, one lowercase letter, and one number'),
];

const verifyEmailValidation = [
  body('token').notEmpty().withMessage('Verification token is required'),
];

// Routes
router.post('/register', registerLimiter, registerValidation, validate, authController.register);
router.post('/login', authLimiter, loginValidation, validate, authController.login);
router.post('/logout', authenticate, authController.logout);
router.get('/me', authenticate, authController.getCurrentUser);
router.post('/refresh-token', authController.refreshToken);

// Password management
router.post('/request-password-reset', passwordResetLimiter, passwordResetRequestValidation, validate, authController.requestPasswordReset);
router.post('/reset-password', passwordResetValidation, validate, authController.resetPassword);
router.post('/change-password', authenticate, changePasswordValidation, validate, authController.changePassword);

// Email verification
router.post('/send-verification-email', authenticate, authController.sendEmailVerification);
router.post('/verify-email', verifyEmailValidation, validate, authController.verifyEmail);

export default router;

