import { DataTypes, Model } from 'sequelize';
import Organisation from './Organisations.js';
import { sequelize } from '../sequelize.js';
import Adress from './Adress.js';

export default class User extends Model {
    static definition(sequelize) {
      User.init(
        {
          username: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
          },
          email: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
          },
          password: {
            type: DataTypes.STRING,
            allowNull: false,
          },
          addressId: {
            type: DataTypes.INTEGER,
            references: {
                model: Adress,
                key: 'id'
            }
          },
	    isConfirmed: {
		type: DataTypes.BOOLEAN,
		allowNull: false,
		defaultValue: false
	    },
	    confirmationToken: {
		type: DataTypes.STRING
	    },
	    confirmationTokenExpiration: {
		type: DataTypes.DATE
	    },
	    googleId: {
		type: DataTypes.STRING,
		allowNull: true,
	    },
	    accessToken: {
		type: DataTypes.STRING,
		allowNull: true,
            },
            refreshToken: {
		type: DataTypes.STRING,
		allowNull: true,
            },
            tokenExpiration: {
		type: DataTypes.DATE,
		allowNull: true,
            }
        },
        {
          tableName: 'user',
          sequelize,
        },
      );
    }
  
    static associate() {
      /*
      User.hasOne(Organisation);
      Organisation.belongsTo(User);
      */
      User.hasOne(Adress)
      Adress.belongsTo(User)
    }
  }
