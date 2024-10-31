export function hasItem(source: number, item: string, amount: number = 1): boolean {
  return exports.ox_inventory.GetItemCount(source, item) >= amount;
}

export async function removeItem(source: number, item: string, quantity: number): Promise<boolean> {
  return exports.ox_inventory.RemoveItem(source, item, quantity);
}

export function sendNotification(source: number, message: string) {
  return exports.chat.addMessage(source, message);
}

export function isAdmin(source: string, group: string): boolean {
  return IsPlayerAceAllowed(source, group);
}
