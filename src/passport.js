import passport from 'passport';
import GoogleStrategy from 'passport-google-oauth20';
//import AzureAdOAuth2Strategy from 'passport-azure-ad-oauth2';
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


// Microsoft OAuth strategy
/*
passport.use(
  new AzureAdOAuth2Strategy(
    {
      clientID: process.env.MICROSOFT_CLIENT_ID,
      clientSecret: process.env.MICROSOFT_CLIENT_SECRET,
      callbackURL: '/auth/microsoft/callback',
    },
    async (accessToken, refreshToken, params, profile, done) => {
      const userProfile = JSON.parse(params.id_token_claims);

      let user = await User.findOne({ where: { microsoftId: userProfile.oid } });

      if (!user) {
        user = await User.create({
          microsoftId: userProfile.oid,
          username: userProfile.name,
          email: userProfile.preferred_username,
        });
      }

      done(null, user);
    }
  )
);
*/
