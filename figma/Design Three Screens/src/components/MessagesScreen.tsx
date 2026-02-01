import React from 'react';
import { motion } from 'motion/react';
import { Search, Archive, ChevronRight, ArrowLeft } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface Conversation {
  id: string;
  name: string;
  avatar: string;
  lastMessage: string;
  time: string;
  unreadCount: number;
}

const MOCK_CHATS: Conversation[] = [
  {
    id: '1',
    name: 'Sarah J.',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah',
    lastMessage: "Is the iPhone still available for swap? I have a Sony A7III.",
    time: '2m ago',
    unreadCount: 2
  },
  {
    id: '2',
    name: 'Marcus W.',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Marcus',
    lastMessage: "The sneakers look great in person. Thanks!",
    time: '1h ago',
    unreadCount: 0
  },
  {
    id: '3',
    name: 'Elena R.',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Elena',
    lastMessage: "Sent the shipping details for the Leica.",
    time: '3h ago',
    unreadCount: 1
  },
  {
    id: '4',
    name: 'Julian B.',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Julian',
    lastMessage: "Can we meet halfway for the chair?",
    time: 'Yesterday',
    unreadCount: 0
  },
  {
    id: '5',
    name: 'Sophia L.',
    avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sophia',
    lastMessage: "That watch is incredible. Do you accept USDT?",
    time: '2 days ago',
    unreadCount: 0
  }
];

export const MessagesScreen: React.FC<{ onBack: () => void }> = ({ onBack }) => {
  return (
    <div className="min-h-screen bg-app-bg pb-32 transition-colors duration-300">
      {/* Header */}
      <header className="pt-4 px-5 mb-6 sticky top-0 bg-app-bg/80 backdrop-blur-xl z-20 border-b border-app-border">
        <div className="flex items-center gap-4 mb-6">
          <button 
            onClick={onBack}
            className="w-12 h-12 bg-app-surface rounded-2xl flex items-center justify-center text-app-text-secondary active:scale-90 transition-all border border-app-border shadow-sm"
          >
            <ArrowLeft size={20} />
          </button>
          <h1 className="text-2xl font-bold text-app-text-primary">Messages</h1>
        </div>

        {/* Search */}
        <div className="relative mb-4">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-app-text-secondary opacity-50" size={18} />
          <input 
            type="text" 
            placeholder="Search conversations..."
            className="w-full bg-app-surface border border-app-border rounded-2xl py-4 pl-12 pr-5 text-[15px] text-app-text-primary placeholder:text-app-text-secondary/30 focus:ring-1 focus:ring-app-text-primary/10 transition-all"
          />
        </div>
      </header>

      <div className="px-5 space-y-2">
        {/* Archive Row */}
        <button className="w-full flex items-center justify-between p-4 bg-app-surface rounded-2xl border border-app-border group active:opacity-70 transition-all mb-4 shadow-sm">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-app-bg flex items-center justify-center text-app-text-secondary border border-app-border">
              <Archive size={18} />
            </div>
            <span className="text-[15px] font-semibold text-app-text-primary">Archived Chats</span>
          </div>
          <ChevronRight size={16} className="text-app-text-secondary opacity-30" />
        </button>

        {/* Chat List */}
        {MOCK_CHATS.map((chat) => (
          <motion.button 
            key={chat.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="w-full flex items-center gap-4 p-4 rounded-[24px] hover:bg-app-surface transition-all group active:scale-[0.98] border border-transparent hover:border-app-border"
          >
            <div className="relative shrink-0">
              <div className="w-14 h-14 rounded-2xl bg-app-surface overflow-hidden border border-app-border transition-colors">
                <ImageWithFallback src={chat.avatar} alt={chat.name} className="w-full h-full object-cover" />
              </div>
              {chat.unreadCount > 0 && (
                 <div className="absolute -top-1 -right-1 w-5 h-5 bg-blue-500 rounded-full border-2 border-app-bg flex items-center justify-center transition-colors">
                    <span className="text-[10px] font-bold text-white">{chat.unreadCount}</span>
                 </div>
              )}
            </div>

            <div className="flex-1 text-left">
              <div className="flex justify-between items-center mb-0.5">
                <h3 className="text-[15px] font-bold text-app-text-primary transition-colors">{chat.name}</h3>
                <span className="text-[12px] text-app-text-secondary font-medium transition-colors">{chat.time}</span>
              </div>
              <p className={`text-[13px] line-clamp-1 transition-colors ${chat.unreadCount > 0 ? 'text-app-text-primary font-semibold' : 'text-app-text-secondary'}`}>
                {chat.lastMessage}
              </p>
            </div>
          </motion.button>
        ))}
      </div>
    </div>
  );
};
