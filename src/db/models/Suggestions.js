import { DataTypes, Model } from "sequelize";

export default class Suggestions extends Model {
  static definition(sequelize) {
    Suggestions.init(
      {
        uuid: {
          type: DataTypes.UUID,
          allowNull: false,
          primaryKey: true,
          defaultValue: DataTypes.UUIDV4,
        },
        title: {
          type: DataTypes.STRING,
          allowNull: false,
        },
        description: {
          type: DataTypes.STRING,
          allowNull: false,
        },
        image: {
          type: DataTypes.STRING,
          allowNull: true,
        },
      },
      {
        sequelize: sequelize,
        tableName: "suggestions",
      }
    );
  }

  static associate() {}
}
