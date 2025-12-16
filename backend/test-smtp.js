import nodemailer from 'nodemailer';
import dotenv from 'dotenv';

dotenv.config();

console.log('🔍 Testing SMTP Configuration...\n');
console.log('Configuration:');
console.log(`  Host: ${process.env.SMTP_HOST}`);
console.log(`  Port: ${process.env.SMTP_PORT}`);
console.log(`  Secure: ${process.env.SMTP_SECURE}`);
console.log(`  User: ${process.env.SMTP_USER}`);
console.log(`  Password: ${process.env.SMTP_PASSWORD ? '***' + process.env.SMTP_PASSWORD.slice(-4) : 'NOT SET'}`);
console.log(`  From: ${process.env.EMAIL_FROM}\n`);

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: parseInt(process.env.SMTP_PORT || '587'),
  secure: process.env.SMTP_SECURE === 'true',
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASSWORD,
  },
  debug: true,
  logger: true,
});

console.log('📧 Testing SMTP connection...\n');

transporter.verify()
  .then(() => {
    console.log('✅ SMTP connection successful!');
    console.log('📨 Sending test email...\n');
    
    return transporter.sendMail({
      from: process.env.EMAIL_FROM,
      to: process.env.SMTP_USER, // Send to self for testing
      subject: 'Test Email - Ordana Clinic',
      text: 'This is a test email from Ordana Clinic backend.',
      html: '<h1>Test Email</h1><p>This is a test email from Ordana Clinic backend.</p>',
    });
  })
  .then((info) => {
    console.log('✅ Test email sent successfully!');
    console.log('Message ID:', info.messageId);
    console.log('Response:', info.response);
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ SMTP Error:', error.message);
    console.error('\n🔧 Troubleshooting Tips:');
    console.error('1. Check if info@whabbiton.com exists in Zoho Mail');
    console.error('2. Verify Two-Factor Authentication is enabled on Zoho');
    console.error('3. Generate a new App-Specific Password:');
    console.error('   https://accounts.zoho.com/home#security/application_password');
    console.error('4. Check if IMAP/POP access is enabled in Zoho Mail settings');
    console.error('5. Try using your regular Zoho password (less secure)');
    console.error('\n📝 Current password in .env:', process.env.SMTP_PASSWORD);
    process.exit(1);
  });
