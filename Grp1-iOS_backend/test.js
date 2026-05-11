const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
async function main() {
  const user = await prisma.user.findFirst();
  if (!user) return console.log("No user");
  console.log("User:", user.id);
  const thread = await prisma.thread.create({
    data: {
      userId: user.id,
      title: 'Draft',
      description: '',
      tags: [],
    }
  });
  console.log("Created thread:", thread.id);
  const draft = await prisma.threadDrafts.create({
    data: {
      userId: user.id,
      threadId: thread.id,
      title: 'Test Draft',
      description: 'Test body',
      tags: [],
    }
  });
  console.log("Created draft:", draft.id);
  const drafts = await prisma.threadDrafts.findMany({ where: { userId: user.id }});
  console.log("Drafts count:", drafts.length);
}
main().catch(console.error).finally(() => prisma.$disconnect());
