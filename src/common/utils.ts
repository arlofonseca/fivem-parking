import { cache } from '@overextended/ox_lib';
import fetch from 'node-fetch';
import * as Config from '../../static/config.json';

export function hasItem(source: number, item: string, amount: number = 1) {
  return exports.ox_inventory.GetItemCount(source, item) >= amount;
}

export async function removeItem(source: number, item: string, amount: number) {
  return exports.ox_inventory.RemoveItem(source, item, amount);
}

export function sendChatMessage(source: number, message: string) {
  return exports.chat.addMessage(source, message);
}

export function getArea(
  coords: { x: number; y: number; z: number },
  areas: { x: number; y: number; z: number; radius: number }[],
) {
  return areas.some((area) => {
    const distance: number = Math.sqrt((coords.x - area.x) ** 2 + (coords.y - area.y) ** 2 + (coords.z - area.z) ** 2);
    return distance <= area.radius;
  });
}

export async function sendLog(message: string) {
  const date = new Date();
  await fetch(Config.Webhook, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      username: cache.resource,
      content: `**[${`${date.getMonth() + 1}/${date.getDate()}/${date.getFullYear()} ${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}`}]** ${message}`,
    }),
  });
}
