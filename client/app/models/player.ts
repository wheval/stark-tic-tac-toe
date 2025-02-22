import mongoose, { Model, Schema } from 'mongoose';

interface Player {
  address: string;
  winnings: number;
  points: number;
}

const playerSchema: Schema = new Schema({
  address: {
    type: String,
    required: true,
    unique: true,
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
});

const Player: Model<Player> = mongoose.models.Player || mongoose.model<Player>('Player', playerSchema);

export default Player;
