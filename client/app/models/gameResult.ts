import mongoose, { Model, Schema } from 'mongoose';

interface GameResult {
  playerAddress: string;
  score: number;
  date: Date;
  gameType: string;
}

const gameResultSchema: Schema = new Schema({
  playerAddress: {
    type: String,
    required: true,
  },
  score: {
    type: Number,
    required: true,
  },
  date: {
    type: Date,
    required: true,
    default: Date.now,
  },
  gameType: {
    type: String,
    required: true,
  },
});

const GameResult: Model<GameResult> =
  mongoose.models.GameResult || mongoose.model<GameResult>('GameResult', gameResultSchema);

export default GameResult;
