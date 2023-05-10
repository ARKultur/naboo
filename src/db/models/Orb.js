import { DataTypes, Model } from 'sequelize';
import { sequelize } from '../sequelize.js';
import Node from './nodes.js';

export default class Orb extends Model {
    static definition(sequelize) {
      Orb.init(
          {
	      keypoints: {
		  type: DataTypes.ARRAY(DataTypes.JSONB),
		  allowNull: false,
	      },
	      descriptors: {
		  type: DataTypes.ARRAY(DataTypes.ARRAY(DataTypes.SMALLINT)),
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
