# Game Results API Documentation

## Endpoints

### POST /api/game-results
Creates a new game result entry in the database.

#### Request Body
```json
{
  "player1": {
    "address": string,    // Player 1's wallet address
    "symbol": "X" | "O"   // Player 1's game symbol
  },
  "player2": {
    "address": string,    // Player 2's wallet address
    "symbol": "X" | "O"   // Player 2's game symbol
  },
  "winner": string | null, // Winner's wallet address or null for draw
  "moves": [
    {
      "position": number,  // Position on the board (0-8)
      "player": string,    // Player's wallet address
      "symbol": "X" | "O"  // Move symbol
    }
  ],
  "startTime": string,    // ISO date string
  "endTime": string,      // ISO date string
  "status": "completed" | "draw"
}
```

#### Response
Success (201):
```json
{
  "message": "Game result saved successfully",
  "data": {
    // Created game result object
  }
}
```

Error (400):
```json
{
  "error": "Missing required field: fieldName"
}
```

Error (500):
```json
{
  "error": "Failed to save game result",
  "details": "Error message"
}
```

### GET /api/game-results
Retrieves the 10 most recent game results.

#### Response
Success (200):
```json
[
  {
    "player1": {
      "address": string,
      "symbol": string
    },
    "player2": {
      "address": string,
      "symbol": string
    },
    "winner": string | null,
    "moves": Array,
    "startTime": string,
    "endTime": string,
    "duration": number,
    "status": string,
    "createdAt": string,
    "updatedAt": string
  }
]
```

Error (500):
```json
{
  "error": "Failed to fetch game results",
  "details": "Error message"
}
```

## Setup Requirements

1. MongoDB Connection
   - Set up a MongoDB database (local or Atlas)
   - Add MongoDB URI to `.env` file:
     ```
     MONGODB_URI=mongodb+srv://<username>:<password>@<cluster>.mongodb.net/<database>?retryWrites=true&w=majority
     ```

2. Environment Variables
   - Copy `.env.example` to `.env`
   - Update the `MONGODB_URI` with your database connection string

## Testing
You can test the API endpoints using the provided `test-game-result.http` file or any API testing tool like Postman or Thunder Client. 