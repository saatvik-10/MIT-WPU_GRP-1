import {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
  DeleteObjectCommand,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

export class R2Service {
  private client: S3Client;
  private bucketName: string;
  private accountId: string;

  constructor() {
    this.accountId = process.env.CLOUDFLARE_ACCOUNT_ID || '';
    const accessKeyId = process.env.CLOUDFLARE_ACCESS_KEY_ID || '';
    const secretAccessKey = process.env.CLOUDFLARE_SECRET_ACCESS_KEY || '';
    this.bucketName = process.env.CLOUDFLARE_BUCKET_NAME || '';

    if (
      !this.accountId ||
      !accessKeyId ||
      !secretAccessKey ||
      !this.bucketName
    ) {
      throw new Error(
        `Missing R2 environment variables. Check:\n` +
          `  CLOUDFLARE_ACCOUNT_ID: ${this.accountId ? '✓' : '✗ MISSING'}\n` +
          `  CLOUDFLARE_ACCESS_KEY_ID: ${accessKeyId ? '✓' : '✗ MISSING'}\n` +
          `  CLOUDFLARE_SECRET_ACCESS_KEY: ${secretAccessKey ? '✓' : '✗ MISSING'}\n` +
          `  CLOUDFLARE_BUCKET_NAME: ${this.bucketName ? '✓' : '✗ MISSING'}`,
      );
    }

    console.log(`[R2] Initialized with:
  Account ID : ${this.accountId.slice(0, 6)}...
  Bucket     : ${this.bucketName}
  Endpoint   : https://${this.accountId}.r2.cloudflarestorage.com`);

    this.client = new S3Client({
      region: 'auto',
      endpoint: `https://${this.accountId}.r2.cloudflarestorage.com`,
      credentials: {
        accessKeyId,
        secretAccessKey,
      },
      forcePathStyle: true,
    });
  }

  async uploadImage(
    folder: string,
    id: string,
    fileName: string,
    buffer: Buffer,
  ): Promise<string> {
    const timestamp = Date.now();
    const sanitizedFileName = fileName.replace(/[^a-zA-Z0-9.\-_]/g, '_');
    const s3Key = `${folder}/${id}/${timestamp}-${sanitizedFileName}`;
    const contentType = this.getContentType(fileName);

    console.log(
      `[R2] Uploading: ${s3Key} (${buffer.length} bytes, ${contentType})`,
    );

    try {
      const command = new PutObjectCommand({
        Bucket: this.bucketName,
        Key: s3Key,
        Body: buffer,
        ContentType: contentType,
      });

      const result = await this.client.send(command);

      console.log(`[R2] ✅ Upload success: ${s3Key} | ETag: ${result.ETag}`);
      return s3Key;
    } catch (error: any) {
      // ✅ Detailed error logging so you can see exactly what went wrong
      console.error(`[R2] ❌ Upload failed for key: ${s3Key}`);
      console.error(
        `[R2] Error code    : ${error.Code || error.code || 'unknown'}`,
      );
      console.error(
        `[R2] HTTP status   : ${error.$metadata?.httpStatusCode || 'unknown'}`,
      );
      console.error(`[R2] Message       : ${error.message}`);
      throw new Error(`R2 upload failed (${error.Code || error.message})`);
    }
  }

  async uploadProfileImage(
    userId: string,
    fileName: string,
    buffer: Buffer,
  ): Promise<string> {
    return this.uploadImage('profile-images', userId, fileName, buffer);
  }

  async uploadThreadImage(
    threadId: string,
    fileName: string,
    buffer: Buffer,
  ): Promise<string> {
    return this.uploadImage('thread-images', threadId, fileName, buffer);
  }

  async getPresignedUrl(
    s3Key: string | null | undefined,
  ): Promise<string | null> {
    if (!s3Key || s3Key.trim() === '') {
      return null;
    }

    try {
      const command = new GetObjectCommand({
        Bucket: this.bucketName,
        Key: s3Key,
      });

      const url = await getSignedUrl(this.client, command, {
        expiresIn: 86400,
      });

      return url;
    } catch (error: any) {
      console.error(
        `[R2] ❌ Presign failed for key: ${s3Key} | ${error.message}`,
      );
      throw new Error(`Failed to generate presigned URL: ${error.message}`);
    }
  }

  async deleteObject(s3Key: string): Promise<void> {
    if (!s3Key || s3Key.trim() === '') return;

    try {
      const command = new DeleteObjectCommand({
        Bucket: this.bucketName,
        Key: s3Key,
      });
      await this.client.send(command);
      console.log(`[R2] ✅ Deleted: ${s3Key}`);
    } catch (error: any) {
      console.error(
        `[R2] ❌ Delete failed for key: ${s3Key} | ${error.message}`,
      );
      throw new Error(`Failed to delete object: ${error.message}`);
    }
  }

  async deleteProfileImage(s3Key: string): Promise<void> {
    return this.deleteObject(s3Key);
  }

  private getContentType(fileName: string): string {
    const ext = fileName.toLowerCase().split('.').pop();
    const contentTypes: Record<string, string> = {
      jpg: 'image/jpeg',
      jpeg: 'image/jpeg',
      png: 'image/png',
      gif: 'image/gif',
      webp: 'image/webp',
    };
    return contentTypes[ext || ''] || 'application/octet-stream';
  }
}

export const r2Service = new R2Service();
