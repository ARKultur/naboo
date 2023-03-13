import {  DataTypes, Model } from 'sequelize';

export default class Contact extends Model {

  static definition(sequelize) {
    Contact.init(
      {
        uuid: {
          type: DataTypes.UUID,
          allowNull: false,
          primaryKey: true,
          defaultValue: DataTypes.UUIDV4
        },
        name: {
          type: DataTypes.STRING,
          allowNull: false,
        },
        category: {
          type: DataTypes.STRING,
          allowNull: false,
        },
        description: {
          type: DataTypes.STRING,
          allowNull: false,
        },
        email: {
          type: DataTypes.STRING,
          allowNull: false,
        },
        processed: {
          type: DataTypes.BOOLEAN,
          allowNull: false,
          defaultValue: false,
        }
      },
      {
        sequelize: sequelize,
        tableName: 'contact',
      }
    )
  }

  static associate() {
  }
}