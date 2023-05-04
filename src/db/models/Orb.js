import { DataTypes, Model } from 'sequelize';
import { sequelize } from '../sequelize.js';
import Node from './nodes.js';

export default class Orb extends Model {
    static definition(sequelize) {
      Orb.init(
          {
	      keypoints: {
		  type: DataTypes.TEXT,
		  allowNull: false,
	      },
	      descriptors: {
		  type: DataTypes.TEXT,
		  allowNull: false,
	      }
        },
        {
          tableName: 'data_orb',
          sequelize,
        },
      );
    }
  
    static associate() {
	Orb.belongsTo(Node, {foreignKey: "orbId", sourceKey: "id"});
	return;
    }
}
