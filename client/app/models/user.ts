import mongoose, { Schema, Document, Model } from "mongoose";

export interface IUser extends Document {
  address: string;
  winnings: number;
  points: number;
  createdAt: Date;
  updatedAt: Date;
}

const userSchema: Schema = new Schema<IUser>(
  {
    address: {
      type: String,
      required: true,
    },
    winnings: {
      type: Number,
      required: true,
      default: 0,
    },
    points: {
      type: Number,
      required: true,
      default: 0,
    },
  },
  { timestamps: true }
);

const User: Model<IUser> = mongoose.models.User || mongoose.model<IUser>("User", userSchema);

export default User;
