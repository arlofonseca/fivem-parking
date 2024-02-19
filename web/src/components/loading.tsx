import clsx from 'clsx';
import { RefreshCw } from 'lucide-react';

interface Props {
  classNames?: string;
}

const Loading: React.FC<Props> = ({ classNames }) => {
  return (
    <>
      <div className={clsx('w-full h-full flex justify-center items-center border', classNames)}>
        <RefreshCw className="text-blue animate-spin" size={20} strokeWidth={2.5} />
      </div>
    </>
  );
};

export default Loading;
