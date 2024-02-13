export function generateType(): string {
    const types: string[] = [
        'car',
        'van',
        'truck',
        'bicycle',
        'motorcycle',
        'boat',
        'helicopter',
        'plane',
        'train',
        'emergency',
    ];
    const chance: number[] = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1];

    const value: number = Math.random();
    let probability: number = 0;

    for (let i: number = 0; i < types.length; i++) {
        probability += chance[i];
        if (value <= probability) {
            return types[i];
        }
    }

    return 'car';
}
