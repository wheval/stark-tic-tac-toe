import connectDB from '../../utils/db';
import User from '../../models/user';
import type { NextApiRequest, NextApiResponse } from 'next';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  await connectDB();

  if (req.method === "GET") {
    const { address } = req.query;

    // Validate the address parameter
    if (!address || Array.isArray(address)) {
      return res.status(400).json({ error: "Address is required and must be a string" });
    }

    try {
      // Fetch the user profile by address
      const user = await User.findOne({ address });

      if (!user) {
        return res.status(404).json({ error: "User not found" });
      }

      res.status(200).json(user);
    } catch (error: unknown) {
      // Handle errors gracefully
      const errMsg = process.env.NODE_ENV === 'development' ? error : "Failed to fetch user profile";
      console.error("Error fetching user profile:", error);
      res.status(500).json({ error: errMsg });
    }
  } else {
    res.setHeader('Allow', ['GET']);
    res.status(405).end(`Method ${req.method} Not Allowed`);
  }
}
