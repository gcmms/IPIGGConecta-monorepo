import pool from '../config/db.js';

const normalizeRows = (rows) => (Array.isArray(rows) ? rows : []);

export const getCommunityPosts = async (userId) => {
  const [rows] = await pool.execute(
    `
      SELECT
        p.id,
        p.user_id,
        p.content,
        p.created_at,
        p.updated_at,
        CONCAT(u.first_name, ' ', u.last_name) AS author_name,
        IFNULL(l.likes_count, 0) AS likes_count,
        IFNULL(c.comments_count, 0) AS comments_count,
        CASE WHEN ul.post_id IS NULL THEN 0 ELSE 1 END AS liked_by_user
      FROM community_posts p
      INNER JOIN users u ON u.id = p.user_id
      LEFT JOIN (
        SELECT post_id, COUNT(*) AS likes_count
        FROM community_post_likes
        GROUP BY post_id
      ) l ON l.post_id = p.id
      LEFT JOIN (
        SELECT post_id, COUNT(*) AS comments_count
        FROM community_post_comments
        GROUP BY post_id
      ) c ON c.post_id = p.id
      LEFT JOIN (
        SELECT post_id
        FROM community_post_likes
        WHERE user_id = ?
      ) ul ON ul.post_id = p.id
      ORDER BY p.created_at DESC
    `,
    [userId || 0]
  );

  return normalizeRows(rows);
};

export const createCommunityPost = async ({ user_id, content }) => {
  const [result] = await pool.execute(
    `
      INSERT INTO community_posts (user_id, content)
      VALUES (?, ?)
    `,
    [user_id, content.trim()]
  );

  const insertedId = result.insertId;

  const [rows] = await pool.execute(
    `
      SELECT
        p.id,
        p.user_id,
        p.content,
        p.created_at,
        p.updated_at,
        CONCAT(u.first_name, ' ', u.last_name) AS author_name
      FROM community_posts p
      INNER JOIN users u ON u.id = p.user_id
      WHERE p.id = ?
    `,
    [insertedId]
  );

  return normalizeRows(rows)[0];
};

export const toggleCommunityLike = async ({ postId, userId }) => {
  const [existingRows] = await pool.execute(
    `
      SELECT id
      FROM community_post_likes
      WHERE post_id = ? AND user_id = ?
      LIMIT 1
    `,
    [postId, userId]
  );

  let liked = false;

  if (Array.isArray(existingRows) && existingRows.length > 0) {
    await pool.execute(
      'DELETE FROM community_post_likes WHERE post_id = ? AND user_id = ?',
      [postId, userId]
    );
  } else {
    await pool.execute(
      `
        INSERT INTO community_post_likes (post_id, user_id)
        VALUES (?, ?)
      `,
      [postId, userId]
    );
    liked = true;
  }

  const [countRows] = await pool.execute(
    `
      SELECT COUNT(*) AS total
      FROM community_post_likes
      WHERE post_id = ?
    `,
    [postId]
  );

  const likesCount =
    Array.isArray(countRows) && countRows.length > 0
      ? Number(countRows[0].total)
      : 0;

  return { liked, likesCount };
};

export const createCommunityComment = async ({ postId, userId, comment }) => {
  await pool.execute(
    `
      INSERT INTO community_post_comments (post_id, user_id, comment)
      VALUES (?, ?, ?)
    `,
    [postId, userId, comment.trim()]
  );

  const [commentRows] = await pool.execute(
    `
      SELECT
        c.id,
        c.post_id,
        c.comment,
        c.created_at,
        CONCAT(u.first_name, ' ', u.last_name) AS author_name
      FROM community_post_comments c
      INNER JOIN users u ON u.id = c.user_id
      WHERE c.post_id = ?
      ORDER BY c.created_at DESC
    `,
    [postId]
  );

  const [countRows] = await pool.execute(
    `
      SELECT COUNT(*) AS total
      FROM community_post_comments
      WHERE post_id = ?
    `,
    [postId]
  );

  const commentsCount =
    Array.isArray(countRows) && countRows.length > 0
      ? Number(countRows[0].total)
      : 0;

  return {
    comments: normalizeRows(commentRows),
    commentsCount
  };
};

export const listCommunityComments = async (postId) => {
  const [rows] = await pool.execute(
    `
      SELECT
        c.id,
        c.post_id,
        c.comment,
        c.created_at,
        CONCAT(u.first_name, ' ', u.last_name) AS author_name
      FROM community_post_comments c
      INNER JOIN users u ON u.id = c.user_id
      WHERE c.post_id = ?
      ORDER BY c.created_at DESC
    `,
    [postId]
  );

  return normalizeRows(rows);
};
