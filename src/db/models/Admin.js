import {  DataTypes, Model } from 'sequelize';
import { sequelize } from '../sequelize.js';

export default class Admin extends Model {
  static definition(sequelize) {
        Admin.init(
        {
          email: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
          },
          password: {
            type: DataTypes.STRING,
            allowNull: false,
          },
          isAdmin: {
              type: DataTypes.BOOLEAN,
              allowNull: false,
              defaultValue: true
          }
        },
        {
          tableName: 'admin',
          sequelize: sequelize,
        },
      );
    }
  
    static associate() {
        return;
    }
  }