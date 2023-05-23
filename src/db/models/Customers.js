import { DataTypes, Model } from 'sequelize';
import { sequelize } from '../sequelize.js';

import {Adress} from './index.js';

export default class Customer extends Model {
    static definition(sequelize) {
      Customer.init(
        {
          first_name: {
            type: DataTypes.STRING,
            allowNull: true,
          },
          last_name: {
            type: DataTypes.STRING,
            allowNull: true,
          },
          addressId: {
            type: DataTypes.INTEGER,
            references: {
                model: Adress,
                key: 'id'
            }
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
          phone_number: {
            type: DataTypes.STRING,
            allowNull: true,
            unique: true,
          },
          username: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
          }
        },
        {
          tableName: 'customers',
          sequelize,
        },
      );
    }
  
    static associate() {
        Customer.hasOne(Adress)
        Adress.belongsTo(Customer)
        return;
    }
}
