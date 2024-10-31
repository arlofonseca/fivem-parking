export function hasItem(source: number, item: string, amount: number = 1): boolean {
  return exports.ox_inventory.GetItemCount(source, item) >= amount;
}

export async function removeItem(source: number, item: string, quantity: number): Promise<boolean> {
  return exports.ox_inventory.RemoveItem(source, item, quantity);
}

export function sendNotification(source: number, message: string) {
  return exports.chat.addMessage(source, message);
}

export function getArea(
  coords: { x: number; y: number; z: number },
  areas: { x: number; y: number; z: number; radius: number }[],
): boolean {
  return areas.some(area => {
    const distance: number = Math.sqrt(
      Math.pow(coords.x - area.x, 2) +
        Math.pow(coords.y - area.y, 2) +
        Math.pow(coords.z - area.z, 2),
    );
    return distance <= area.radius;
  });
}
