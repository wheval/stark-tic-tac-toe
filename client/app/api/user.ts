import connectDB from '../utils/db';
import User from '../models/user';
import type { NextApiRequest, NextApiResponse } from 'next';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  await connectDB();

  if (req.method === "POST") {
    try {
      const { address, winnings, points } = req.body;

      if (!address) {
        return res.status(400).json({ error: "Address is required" });
      }

      const newUser = new User({
        address,
        winnings: winnings || 0,
        points: points || 0,
      });

      await newUser.save();

      return res.status(201).json({ message: "User created successfully", user: newUser });
    } catch (error) {
      console.error("Error creating user:", error); // ✅ Using the error variable
      return res.status(500).json({ error: "Internal Server Error" });
    }
  } else {
    return res.status(405).json({ error: "Method not allowed" });
  }
}
