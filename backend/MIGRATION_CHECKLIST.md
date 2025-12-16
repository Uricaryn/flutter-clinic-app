# PostgreSQL Migration Checklist

Track your progress as you migrate from Firebase to PostgreSQL.

## Phase 1: Database Setup ✅

- [x] Create backend directory structure
- [x] Install Node.js dependencies (package.json)
- [x] Create database schema (001_initial_schema.sql)
- [x] Create migration runner (run-migrations.js)
- [x] Create database configuration (database.js)
- [x] Set up environment variables (.env.example)
- [x] Create setup documentation (README.md, SETUP.md)
- [x] Create database documentation (DATABASE.md)
- [x] Add .gitignore for backend
- [x] Create test script (test-connection.js)

## Phase 2: Local Database Setup ⏳

- [ ] Install PostgreSQL locally
- [ ] Create clinic_db database
- [ ] Copy .env.example to .env
- [ ] Configure DATABASE_URL in .env
- [ ] Run migrations: `npm run migrate`
- [ ] Verify setup: `node test-connection.js`
- [ ] Test queries with verify-schema.sql

## Phase 3: Backend API Development ⏳

### Authentication
- [ ] Create auth middleware (JWT verification)
- [ ] Implement register endpoint
- [ ] Implement login endpoint
- [ ] Implement refresh token endpoint
- [ ] Implement logout endpoint
- [ ] Add password reset functionality

### Core API Endpoints
- [ ] Clinics CRUD endpoints
- [ ] Users CRUD endpoints
- [ ] Patients CRUD endpoints
- [ ] Appointments CRUD endpoints
- [ ] Procedures CRUD endpoints
- [ ] Stock items CRUD endpoints
- [ ] Expenses CRUD endpoints
- [ ] Operators CRUD endpoints

### Business Logic
- [ ] Stock deduction on appointment completion
- [ ] Low stock alerts
- [ ] Appointment conflict detection
- [ ] Payment tracking
- [ ] Revenue calculations
- [ ] Expense reports

### Real-time Features
- [ ] WebSocket server setup
- [ ] PostgreSQL LISTEN/NOTIFY integration
- [ ] Real-time appointment updates
- [ ] Real-time stock updates
- [ ] Client subscription management

## Phase 4: Flutter App Updates ⏳

### Dependencies
- [ ] Add dio/http package
- [ ] Add web_socket_channel
- [ ] Add flutter_secure_storage
- [ ] Remove firebase_core
- [ ] Remove firebase_auth
- [ ] Remove cloud_firestore

### Configuration
- [ ] Create api_config.dart with base URLs
- [ ] Create app_mode.dart (Firebase/PostgreSQL toggle)
- [ ] Set up dual-mode configuration system

### Services Layer
- [ ] Create ApiService (HTTP client wrapper)
- [ ] Create WebSocketService (real-time updates)
- [ ] Create new AuthService (JWT-based)
- [ ] Create DatabaseService abstraction
- [ ] Implement FirebaseDatabaseService (keep existing)
- [ ] Implement PostgresqlDatabaseService (new)

### Models
- [ ] Update all models: Timestamp → DateTime
- [ ] Add fromJson/toJson for API responses
- [ ] Update appointment_model.dart
- [ ] Update patient_model.dart
- [ ] Update stock_item_model.dart
- [ ] Update clinic_model.dart
- [ ] Update procedure_model.dart
- [ ] Update expense_model.dart

### Providers
- [ ] Update auth_provider for JWT
- [ ] Create database_provider with mode switching
- [ ] Update all repository providers
- [ ] Add token storage provider
- [ ] Add WebSocket provider

### UI Updates
- [ ] Replace StreamBuilder with API calls + WebSocket
- [ ] Add loading states for API calls
- [ ] Add error handling for network failures
- [ ] Update login screen
- [ ] Update all list screens
- [ ] Update all detail screens
- [ ] Test dual-mode switching

## Phase 5: Data Migration ⏳

- [ ] Export all Firestore collections
- [ ] Create Firebase to PostgreSQL migration script
- [ ] Migrate clinics collection
- [ ] Migrate users collection
- [ ] Migrate patients collection
- [ ] Migrate procedures collection
- [ ] Migrate stock_items collection
- [ ] Migrate appointments collection
- [ ] Migrate expenses collection
- [ ] Migrate operators collection
- [ ] Verify data integrity
- [ ] Test with migrated data

## Phase 6: Testing ⏳

### Backend Testing
- [ ] Write unit tests for models
- [ ] Write unit tests for services
- [ ] Write integration tests for API endpoints
- [ ] Test authentication flow
- [ ] Test CRUD operations
- [ ] Test WebSocket connections
- [ ] Test error handling
- [ ] Load testing
- [ ] Security testing

### Flutter Testing
- [ ] Test API service
- [ ] Test WebSocket service
- [ ] Test auth flow with JWT
- [ ] Integration tests for key features
- [ ] Test dual-mode switching
- [ ] Test error scenarios
- [ ] Test offline handling
- [ ] Performance testing

### End-to-End Testing
- [ ] Complete user journeys
- [ ] Cross-platform testing (iOS, Android, Web)
- [ ] Real-time updates verification
- [ ] Payment flow testing
- [ ] Stock management testing

## Phase 7: Deployment Preparation ⏳

### Backend
- [ ] Choose hosting provider (DigitalOcean/AWS/etc)
- [ ] Set up production PostgreSQL database
- [ ] Configure production environment variables
- [ ] Set up SSL/TLS certificates
- [ ] Configure CORS for production
- [ ] Set up logging and monitoring
- [ ] Configure automated backups
- [ ] Set up CI/CD pipeline

### Frontend
- [ ] Update API URLs for production
- [ ] Build production APK/IPA
- [ ] Test with production backend
- [ ] Update app version
- [ ] Prepare release notes

## Phase 8: Production Deployment ⏳

- [ ] Deploy backend to production
- [ ] Run production database migrations
- [ ] Migrate production data from Firebase
- [ ] Update Flutter app config to PostgreSQL mode
- [ ] Deploy new app version to stores
- [ ] Monitor for errors
- [ ] Set up alerts and monitoring
- [ ] Document production procedures

## Phase 9: Post-Migration ⏳

- [ ] Monitor system performance
- [ ] Monitor error rates
- [ ] Gather user feedback
- [ ] Fix any critical issues
- [ ] Optimize slow queries
- [ ] Remove Firebase dependencies
- [ ] Remove Firebase from Flutter app
- [ ] Clean up Firebase project
- [ ] Update documentation
- [ ] Train users on any changes

## Rollback Plan 🆘

If issues occur, you can quickly rollback:

### Flutter App Rollback
```dart
// In app_mode.dart
static const DatabaseMode mode = DatabaseMode.firebase; // ← Change back
```

Then rebuild and redeploy app.

### Complete Rollback
- [ ] Revert to backup branch: `git checkout backup/firebase-stable-[date]`
- [ ] Or checkout tag: `git checkout v1.0.0-firebase-stable`
- [ ] Rebuild and redeploy Flutter app
- [ ] Keep backend running for future migration attempt

## Timeline Estimates

| Phase | Estimated Time | Status |
|-------|----------------|--------|
| Phase 1: Database Setup | 1-2 days | ✅ Complete |
| Phase 2: Local Setup | 0.5 days | ⏳ Pending |
| Phase 3: Backend API | 4-6 days | ⏳ Pending |
| Phase 4: Flutter Updates | 4-6 days | ⏳ Pending |
| Phase 5: Data Migration | 1-2 days | ⏳ Pending |
| Phase 6: Testing | 3-4 days | ⏳ Pending |
| Phase 7: Deployment Prep | 1-2 days | ⏳ Pending |
| Phase 8: Production Deploy | 1 day | ⏳ Pending |
| Phase 9: Post-Migration | Ongoing | ⏳ Pending |
| **Total** | **~2.5-3.5 weeks** | |

## Notes

- Keep Firebase running in production during entire migration
- Test thoroughly in staging before production deployment
- Use dual-mode configuration for safe transition
- Have rollback plan ready at all times
- Monitor closely during first week after migration

## Success Criteria

- [ ] All features working in PostgreSQL mode
- [ ] Performance equal or better than Firebase
- [ ] No data loss during migration
- [ ] Users can use app without issues
- [ ] Real-time updates working correctly
- [ ] All tests passing
- [ ] Production monitoring shows healthy system

## Questions/Issues

Document any questions or issues that arise:

1. _Example: Need to decide on cloud hosting provider_
2. _Example: Consider rate limiting strategy_
3. _Your questions here..._

---

**Current Phase**: Phase 1 - Database Setup ✅ COMPLETE

**Next Step**: Phase 2 - Install PostgreSQL locally and test the schema

**Last Updated**: 2024-12-16
