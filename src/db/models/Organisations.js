import {  DataTypes, Model } from 'sequelize';
import User from './Users.js';
import { sequelize } from '../sequelize.js';

export default class Organisation extends Model {
  static definition(sequelize) {
        Organisation.init(
        {
          name: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
          }
        },
        {
          tableName: 'organisations',
          sequelize: sequelize,
        },
      );
    }
  
    static associate() {
        Organisation.hasMany(User, { onDelete: 'cascade', foreignKey: 'id' });
        User.belongsTo(Organisation, { foreignKey: 'id'});
    }
  }