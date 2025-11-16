import 'dotenv/config';
import mysql from 'mysql2/promise';

const useSocket = Boolean(process.env.DB_SOCKET_PATH);

const configuredHost = process.env.DB_HOST || '127.0.0.1';
const tcpHost =
  configuredHost.toLowerCase() === 'localhost' ? '127.0.0.1' : configuredHost;

const pool = mysql.createPool({
  host: useSocket ? undefined : tcpHost,
  socketPath: useSocket ? process.env.DB_SOCKET_PATH : undefined,
  port: useSocket ? undefined : Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'ipiggconect',
  waitForConnections: true,
  connectionLimit: Number(process.env.DB_CONNECTION_LIMIT) || 10,
  queueLimit: 0
});

pool.on('error', (error) => {
  console.error('Unexpected error on MySQL client', error);
  process.exit(1);
});

export default pool;
