import {  DataTypes, Model } from 'sequelize';
import { sequelize } from '../sequelize.js';
import Adress from './Adress.js'
import Guide from './Guides.js';

function isRanged(pos) {
    return pos > -180.0 && pos < 180.0;
}

export default class Node extends Model {
    static definition(sequelize) {
      Node.init(
        {
          name: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
          },
          longitude: {
            type: DataTypes.DOUBLE,
            allowNull: false,
            isRanged: true
          },
          latitude: {
            type: DataTypes.DOUBLE,
            allowNull: false,
            isRanged: true
          },
          addressId: {
            type: DataTypes.INTEGER,
            references: {
                model: Adress,
                key: 'id'
            }
          }
        },
        {
          tableName: 'nodes',
          sequelize,
        },
      );
    }
  
    static associate() {
        Node.hasOne(Adress)
        Node.hasMany(Guide,{ onDelete: 'cascade', foreignKey: 'guideId' })
        return;
    }
}