import passport from 'passport';
import GoogleStrategy from 'passport-google-oauth20';
import User from './db/models/Users.js';

passport.serializeUser((user, done) => {
  done(null, user.id);
});

passport.deserializeUser(async (id, done) => {
    const user = await User.findByPk(id);
    done(null, user);
});

// Google OAuth strategy
passport.use(
  new GoogleStrategy(
    {
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
	callbackURL: '/auth/google/callback',
	scope: ['profile', 'email']
    },
    async (accessToken, refreshToken, profile, done) => {
      let user = await User.findOne({ where: { googleId: profile.id } });

      if (!user) {
        user = await User.create({
          googleId: profile.id,
          username: profile.displayName,
            email: profile.emails[0].value,
	    password: "jaj"
        });
      }

      done(null, user);
    }
  )
);
