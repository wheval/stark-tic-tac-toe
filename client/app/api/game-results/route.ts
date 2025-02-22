import { NextResponse } from 'next/server';
import connectDB from '../../lib/mongodb';
import GameResult from '../../models/GameResult';

export async function POST(request: Request) {
  try {
    const body = await request.json();

    // Validate required fields
    const requiredFields = ['player1', 'player2', 'moves', 'startTime', 'endTime', 'status'];
    for (const field of requiredFields) {
      if (!body[field]) {
        return NextResponse.json(
          { error: `Missing required field: ${field}` },
          { status: 400 }
        );
      }
    }

    // Calculate duration
    const startTime = new Date(body.startTime);
    const endTime = new Date(body.endTime);
    const duration = Math.floor((endTime.getTime() - startTime.getTime()) / 1000);

    // Connect to database
    await connectDB();

    // Create new game result
    const gameResult = await GameResult.create({
      ...body,
      duration,
    });

    return NextResponse.json(
      { message: 'Game result saved successfully', data: gameResult },
      { status: 201 }
    );
  } catch (error: any) {
    console.error('Error saving game result:', error);
    return NextResponse.json(
      { error: 'Failed to save game result', details: error.message },
      { status: 500 }
    );
  }
}

// GET endpoint to fetch game results
export async function GET() {
  try {
    await connectDB();
    const results = await GameResult.find({})
      .sort({ createdAt: -1 })
      .limit(10);

    return NextResponse.json(results);
  } catch (error: any) {
    console.error('Error fetching game results:', error);
    return NextResponse.json(
      { error: 'Failed to fetch game results', details: error.message },
      { status: 500 }
    );
  }
} 