import {  DataTypes, Model } from 'sequelize';
import { sequelize } from '../sequelize.js';

export default class Adress extends Model {
    static definition(sequelize) {
      Adress.init(
        {
            country: {
                type: DataTypes.STRING,
                allowNull: false
            },
            postcode: {
                type: DataTypes.FLOAT,
                allowNull: false
            },
            state: {
                type: DataTypes.STRING,
                allowNull: false
            },
            street_address: {
                type: DataTypes.STRING,
                allowNull: false 
            },
            city: {
                type: DataTypes.STRING,
                allowNull: false
            }
        },
        {
          tableName: 'adresses',
          sequelize,
        },
      );
    }
  
    static associate() {
        return;
    }
}