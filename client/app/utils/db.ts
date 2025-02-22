import mongoose from 'mongoose';

interface GlobalWithMongoose extends Global {
  mongoose: {
    conn: typeof mongoose | null;
    promise: Promise<typeof mongoose> | null;
  } | undefined;
}

declare const global: GlobalWithMongoose;

if (!process.env.MONGODB_URI) {
  throw new Error('Please define the MONGODB_URI environment variable inside .env');
}

const MONGODB_URI = process.env.MONGODB_URI;

let cached = global.mongoose;

if (!cached) {
  cached = global.mongoose = { conn: null, promise: null };
}

async function connectDB(): Promise<typeof mongoose> {
  if (cached?.conn) {
    return cached.conn;
  }

  if (!cached?.promise) {
    const opts = {
      bufferCommands: false,
    };

    if (!cached) {
      cached = global.mongoose = { conn: null, promise: null };
    }

    cached.promise = mongoose.connect(MONGODB_URI!, opts);
  }

  try {
    if (!cached) {
      throw new Error('MongoDB connection not initialized');
    }
    const conn = await cached.promise;
    cached.conn = conn;
    return conn;
  } catch (e) {
    if (cached) {
      cached.promise = null;
    }
    throw e;
  }
}

export default connectDB;
