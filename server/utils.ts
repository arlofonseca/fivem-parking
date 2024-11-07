import fetch from 'node-fetch';
import * as config from '../config.json';

export function hasItem(source: number, item: string, amount: number = 1): boolean {
  return exports.ox_inventory.GetItemCount(source, item) >= amount;
}

export async function removeItem(source: number, item: string, amount: number): Promise<boolean> {
  return exports.ox_inventory.RemoveItem(source, item, amount);
}

export function sendNotification(source: number, message: string) {
  return exports.chat.addMessage(source, message);
}

export function getArea(coords: { x: number; y: number; z: number }, areas: { x: number; y: number; z: number; radius: number }[]): boolean {
  return areas.some(area => {
    const distance: number = Math.sqrt(Math.pow(coords.x - area.x, 2) + Math.pow(coords.y - area.y, 2) + Math.pow(coords.z - area.z, 2));
    return distance <= area.radius;
  });
}

// discord isn't recommended at all but 
// who cares. im not paying/going the extra
// mile to see some logs. you can adjust this to
// fit your needs if using fivemanage, datadog, etc.
export async function sendLog(message: string): Promise<void> {
  const webhook: string = config.webhook_url;
  const date = new Date();
  const formatDate = `${date.getMonth() + 1}/${date.getDate()}/${date.getFullYear()} ${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}`;
  const payload = { content: `**[${formatDate}]** ${message}`, username: 'vehicles' };

  try {
    await fetch(webhook, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
  } catch (error) {
    console.error('sendLog:', error);
  }
}
