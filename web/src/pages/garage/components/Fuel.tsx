import { Text } from '@mantine/core';
import React from 'react';

interface Props {
    amount?: number;
}

const Fuel: React.FC<Props> = () => {
    return (
        <Text
            style={{
                width: 'auto',
                height: '15px',
                fontWeight: '400',
                fontSize: '12px',
                lineHeight: '15px',
                color: '#FFFFFF',
                position: 'absolute',
                top: '1px',
                right: '1px',
            }}
        >
            Fuel: 21.2%
        </Text>
    );
};

export default Fuel;
