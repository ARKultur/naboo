import { DataTypes, Model } from 'sequelize';
import { sequelize } from '../sequelize.js';
import Node from './nodes.js';

export default class Guide extends Model {
    static definition(sequelize) {
      Guide.init(
        {
          text: {
            type: DataTypes.STRING,
            allowNull: false
          }
        },
        {
          tableName: 'guide',
          sequelize,
        },
      );
    }
  
    static associate() {
        return;
    }
  }