import { DataTypes, Model } from 'sequelize';
import { sequelize } from '../sequelize.js';

export default class Orm extends Model {
    static definition(sequelize) {
      Orm.init(
          {
	      image_id: {
		  type: DataTypes.INTEGER,
		  primaryKey: true,
		  autoIncrement: true,
	      },
	      keypoints: {
		  type: DataTypes.TEXT,
		  allowNull: false,
	      },
	      descriptors: {
		  type: DataTypes.TEXT,
		  allowNull: false,
	      },
        },
        {
          tableName: 'orm_data',
          sequelize,
        },
      );
    }
  
    static associate() {
    }
}
