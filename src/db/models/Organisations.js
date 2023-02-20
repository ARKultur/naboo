import {  DataTypes, Model } from 'sequelize';
import User from './Users.js';
import { sequelize } from '../sequelize.js';
import Adress from './Adress.js';
import Node from './nodes.js';

export default class Organisation extends Model {
  static definition(sequelize) {
        Organisation.init(
        {
          name: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true,
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
          tableName: 'organisations',
          sequelize: sequelize,
        },
      );
    }
  
    static associate() {
        Organisation.hasMany(User, { onDelete: 'cascade'});
        User.belongsTo(Organisation);
        Organisation.hasMany(Node, { onDelete: 'cascade'})
        Node.belongsTo(Organisation);
        Organisation.hasOne(Adress);
        Adress.belongsTo(Organisation);
    }
  }