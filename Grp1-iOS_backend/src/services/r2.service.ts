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
  private accessKeyId: string;
  private secretAccessKey: string;

  constructor() {
    this.accountId = process.env.CLOUDFLARE_ACCOUNT_ID || '';
    this.accessKeyId = process.env.CLOUDFLARE_ACCESS_KEY_ID || '';
    this.secretAccessKey = process.env.CLOUDFLARE_SECRET_ACCESS_KEY || '';
    this.bucketName = process.env.CLOUDFLARE_BUCKET_NAME || '';

    if (
      !this.accountId ||
      !this.accessKeyId ||
      !this.secretAccessKey ||
      !this.bucketName
    ) {
      throw new Error('Missing required Cloudflare R2 environment variables');
    }

    this.client = new S3Client({
      region: 'auto',
      credentials: {
        accessKeyId: this.accessKeyId,
        secretAccessKey: this.secretAccessKey,
      },
      endpoint: `https://${this.accountId}.r2.cloudflarestorage.com`,
    });
  }

  async uploadProfileImage(
    userId: string,
    fileName: string,
    buffer: Buffer,
  ): Promise<string> {
    const timestamp = Date.now();
    const s3Key = `profile-images/${userId}/${timestamp}-${fileName}`;

    try {
      const command = new PutObjectCommand({
        Bucket: this.bucketName,
        Key: s3Key,
        Body: buffer,
        ContentType: this.getContentType(fileName),
      });

      await this.client.send(command);
      console.log(`✓ Profile image uploaded: ${s3Key}`);
      return s3Key;
    } catch (error) {
      console.error('Error uploading to R2:', error);
      throw new Error(
        `Failed to upload profile image to R2: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  async getPresignedUrl(s3Key: string): Promise<string> {
    try {
      const command = new GetObjectCommand({
        Bucket: this.bucketName,
        Key: s3Key,
      });

      const url = await getSignedUrl(this.client, command, {
        expiresIn: 86400,
      });
      return url;
    } catch (error) {
      console.error('Error generating presigned URL:', error);
      throw new Error(
        `Failed to generate presigned URL: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  async deleteProfileImage(s3Key: string): Promise<void> {
    try {
      const command = new DeleteObjectCommand({
        Bucket: this.bucketName,
        Key: s3Key,
      });

      await this.client.send(command);
      console.log(`✓ Profile image deleted: ${s3Key}`);
    } catch (error) {
      console.error('Error deleting from R2:', error);
      throw new Error(
        `Failed to delete profile image from R2: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
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
    return contentTypes[ext || ''] || 'image/jpeg';
  }

  getPublicUrl(s3Key: string): string {
    return `https://${this.bucketName}.${this.accountId}.r2.cloudflarestorage.com/${s3Key}`;
  }
}

export const r2Service = new R2Service();
