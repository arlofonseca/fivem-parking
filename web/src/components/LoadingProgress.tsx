import clsx from 'clsx';
import { RefreshCw } from 'lucide-react';

interface Props {
  className?: string;
}

const Loading: React.FC<Props> = ({ className }: Props) => {
  return (
    <>
      <div className={clsx(className)}>
        <RefreshCw className="text-blue animate-spin" size={20} strokeWidth={2.5} />
      </div>
    </>
  );
};

export default Loading;
