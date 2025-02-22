// GET API Route for fetching all players
import type { NextApiRequest, NextApiResponse } from 'next';
import connectDB from '../utils/db';
import Player from '../models/player';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  await connectDB();

  if (req.method === 'GET') {
    try {
      // Fetch all players
      const players = await Player.find({});
      res.status(200).json(players);
    } catch (error) {
      console.error('Error fetching players:', error);
      res.status(500).json({ error: 'Failed to fetch players' });
    }
  } else {
    res.setHeader('Allow', ['GET']);
    res.status(405).end(`Method ${req.method} Not Allowed`);
  }
}
