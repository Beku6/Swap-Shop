import React from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { 
  ArrowUpRight, 
  ArrowDownLeft, 
  History, 
  Plus, 
  CreditCard, 
  ChevronRight, 
  Repeat, 
  Palette,
  Check,
  X
} from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { useTheme } from './ThemeProvider';

type CardDesign = 'gradient' | 'classic' | 'photo' | 'minimal' | 'metallic';

interface DesignOption {
  id: CardDesign;
  name: string;
  previewClass: string;
  isLight?: boolean;
}

const DESIGNS: DesignOption[] = [
  { id: 'gradient', name: 'Deep Sea', previewClass: 'bg-gradient-to-br from-[#2D5BFF] via-[#8B5CF6] to-[#EC4899]' },
  { id: 'classic', name: 'Noir', previewClass: 'bg-[#161618] border border-white/5' },
  { id: 'photo', name: 'Horizon', previewClass: 'bg-[#0A0A0B]' }, // Uses image
  { id: 'minimal', name: 'Canvas', previewClass: 'bg-white', isLight: true },
  { id: 'metallic', name: 'Titanium', previewClass: 'bg-neutral-800' },
];

export const WalletScreen: React.FC = () => {
  const [selectedDesign, setSelectedDesign] = React.useState<CardDesign>('gradient');
  const [isDesignSheetOpen, setIsDesignSheetOpen] = React.useState(false);
  const { theme } = useTheme();

  const currentDesign = DESIGNS.find(d => d.id === selectedDesign);
  const isLightCard = currentDesign?.isLight;

  return (
    <div className="pb-32 pt-4 px-5 bg-app-bg transition-colors duration-300 min-h-screen">
      <header className="mb-8">
        <h1 className="text-3xl font-bold tracking-tight text-app-text-primary mb-1 transition-colors">Wallet</h1>
        <p className="text-app-text-secondary text-sm transition-colors">Secure assets and transactions</p>
      </header>

      {/* Main Card */}
      <motion.div 
        layoutId="wallet-card"
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className={`relative h-56 w-full rounded-[32px] overflow-hidden mb-8 shadow-2xl transition-all duration-500 border border-app-border ${
          selectedDesign === 'minimal' ? 'bg-white' : 'bg-app-surface'
        }`}
      >
        {/* Background Layers */}
        {selectedDesign === 'gradient' && (
          <div className="absolute inset-0 bg-gradient-to-br from-[#2D5BFF] via-[#8B5CF6] to-[#EC4899] opacity-90 transition-opacity" />
        )}
        
        {selectedDesign === 'classic' && (
          <div className="absolute inset-0 bg-[#0A0A0B] opacity-100 transition-opacity">
            <div className="absolute inset-0 opacity-[0.03] bg-[url('https://www.transparenttextures.com/patterns/carbon-fibre.png')]" />
          </div>
        )}

        {selectedDesign === 'photo' && (
          <div className="absolute inset-0 transition-opacity">
             <ImageWithFallback 
                src="https://images.unsplash.com/photo-1760224254117-7a40f7f03fe2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhYnN0cmFjdCUyMGRhcmslMjBwcmVtaXVtJTIwdGV4dHVyZSUyMGx1eHVyeXxlbnwxfHx8fDE3Njk4NTcyMzV8MA&ixlib=rb-4.1.0&q=80&w=1080"
                className="w-full h-full object-cover"
                alt="Card Background"
             />
             <div className="absolute inset-0 bg-black/20" />
          </div>
        )}

        {selectedDesign === 'metallic' && (
          <div className="absolute inset-0 bg-[#242426] transition-opacity">
            <div className="absolute inset-0 bg-gradient-to-tr from-transparent via-white/5 to-transparent opacity-50" />
            <div className="absolute inset-0 border border-white/10 rounded-[32px]" />
          </div>
        )}

        <div className={`absolute inset-0 ${isLightCard ? 'bg-[radial-gradient(circle_at_top_right,rgba(0,0,0,0.05),transparent)]' : 'bg-[radial-gradient(circle_at_top_right,rgba(255,255,255,0.2),transparent)]'}`} />
        
        {/* Design Switcher Button */}
        <button 
          onClick={() => setIsDesignSheetOpen(true)}
          className={`absolute top-6 right-6 p-2 rounded-full backdrop-blur-xl border transition-all active:scale-90 z-20 ${
            isLightCard 
              ? 'bg-black/5 border-black/10 text-black/40' 
              : 'bg-white/10 border-white/10 text-white/40'
          }`}
        >
          <Palette size={18} />
        </button>
        
        <div className="relative h-full p-8 flex flex-col justify-between z-10">
          <div>
            <span className={`text-[13px] font-medium tracking-wider uppercase transition-colors ${isLightCard ? 'text-black/40' : 'text-white/60'}`}>
              Total Balance
            </span>
            <div className="flex items-baseline gap-2 mt-1">
              <span className={`text-4xl font-bold tracking-tight transition-colors ${isLightCard ? 'text-black' : 'text-white'}`}>
                $14,250.00
              </span>
            </div>
          </div>
          
          <div className="flex justify-between items-end">
            <div className={isLightCard ? 'text-black/60' : 'text-white/80'}>
                <div className={`text-[10px] uppercase tracking-widest mb-1 opacity-60`}>Account Holder</div>
                <div className="text-sm font-medium">FELIX ANDERSON</div>
            </div>
            <div className="flex -space-x-3">
               <div className={`w-8 h-8 rounded-full backdrop-blur-md border transition-colors ${isLightCard ? 'bg-black/10 border-black/20' : 'bg-white/20 border-white/30'}`} />
               <div className={`w-8 h-8 rounded-full backdrop-blur-md border transition-colors ${isLightCard ? 'bg-black/10 border-black/20' : 'bg-white/20 border-white/30'}`} />
            </div>
          </div>
        </div>
      </motion.div>

      {/* Actions */}
      <div className="grid grid-cols-4 gap-4 mb-10">
        {[
          { icon: Plus, label: 'Add', color: 'bg-blue-500/10 text-blue-500' },
          { icon: ArrowUpRight, label: 'Send', color: 'bg-violet-500/10 text-violet-500' },
          { icon: ArrowDownLeft, label: 'Request', color: 'bg-emerald-500/10 text-emerald-500' },
          { icon: History, label: 'Log', color: 'bg-app-text-secondary/10 text-app-text-secondary' },
        ].map((action, i) => (
          <div key={i} className="flex flex-col items-center gap-2">
            <button className={`w-full aspect-square rounded-2xl flex items-center justify-center transition-all active:scale-90 ${action.color} border border-transparent hover:border-app-border`}>
              <action.icon size={22} />
            </button>
            <span className="text-[11px] font-bold text-app-text-secondary transition-colors uppercase tracking-widest">{action.label}</span>
          </div>
        ))}
      </div>

      {/* Transactions */}
      <section>
        <div className="flex justify-between items-center mb-5">
          <h3 className="text-lg font-bold text-app-text-primary transition-colors">Recent Activity</h3>
          <button className="text-[13px] font-bold text-blue-500 uppercase tracking-wider">View All</button>
        </div>
        
        <div className="space-y-3">
          {[
            { title: 'iPhone 15 Pro Max', date: 'Just now', amount: '-$1,200.00', type: 'Purchase', icon: ArrowUpRight },
            { title: 'Barter Swap: Leica Q3', date: 'Yesterday', amount: 'In Escrow', type: 'Swap', icon: Repeat },
            { title: 'Wallet Top-up', date: '2 days ago', amount: '+$500.00', type: 'Deposit', icon: ArrowDownLeft },
            { title: 'Sold: Designer Chair', date: '4 days ago', amount: '+$450.00', type: 'Sale', icon: ArrowDownLeft },
          ].map((tx, i) => (
            <div key={i} className="flex items-center gap-4 p-4 bg-app-surface rounded-[24px] group cursor-pointer hover:bg-app-bg transition-all border border-app-border shadow-sm">
              <div className="w-12 h-12 rounded-xl bg-app-bg flex items-center justify-center text-app-text-secondary border border-app-border transition-colors">
                <tx.icon size={20} />
              </div>
              <div className="flex-1">
                <div className="text-[15px] font-bold text-app-text-primary transition-colors">{tx.title}</div>
                <div className="text-[12px] text-app-text-secondary transition-colors">{tx.date} • {tx.type}</div>
              </div>
              <div className="text-right">
                <div className={`text-[15px] font-bold ${tx.amount.startsWith('+') ? 'text-emerald-500' : 'text-app-text-primary'}`}>
                  {tx.amount}
                </div>
                <ChevronRight size={14} className="text-app-text-secondary opacity-30 ml-auto mt-1" />
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Design Selector Bottom Sheet */}
      <AnimatePresence>
        {isDesignSheetOpen && (
          <>
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsDesignSheetOpen(false)}
              className="fixed inset-0 bg-black/60 backdrop-blur-sm z-[60]"
            />
            <motion.div 
              initial={{ y: '100%' }}
              animate={{ y: 0 }}
              exit={{ y: '100%' }}
              transition={{ type: 'spring', damping: 25, stiffness: 300 }}
              className="fixed bottom-0 left-0 right-0 bg-app-surface rounded-t-[32px] p-6 pb-12 z-[70] border-t border-app-border shadow-2xl max-w-lg mx-auto"
            >
              <div className="flex justify-between items-center mb-8">
                <div>
                  <h2 className="text-xl font-bold text-app-text-primary">Card Design</h2>
                  <p className="text-app-text-secondary text-[13px]">Choose a style for your wallet</p>
                </div>
                <button 
                  onClick={() => setIsDesignSheetOpen(false)}
                  className="w-10 h-10 bg-app-bg rounded-full flex items-center justify-center text-app-text-secondary border border-app-border"
                >
                  <X size={20} />
                </button>
              </div>

              <div className="grid grid-cols-1 gap-4">
                {DESIGNS.map((design) => (
                  <button
                    key={design.id}
                    onClick={() => {
                      setSelectedDesign(design.id);
                      setIsDesignSheetOpen(false);
                    }}
                    className={`flex items-center justify-between p-4 rounded-2xl border transition-all ${
                      selectedDesign === design.id 
                        ? 'bg-app-bg border-blue-500/50' 
                        : 'bg-app-bg border-app-border'
                    }`}
                  >
                    <div className="flex items-center gap-4">
                      <div className={`w-14 h-9 rounded-lg shadow-inner overflow-hidden relative ${design.previewClass} border border-app-border`}>
                         {design.id === 'photo' && (
                            <img 
                              src="https://images.unsplash.com/photo-1760224254117-7a40f7f03fe2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhYnN0cmFjdCUyMGRhcmslMjBwcmVtaXVtJTIwdGV4dHVyZSUyMGx1eHVyeXxlbnwxfHx8fDE3Njk4NTcyMzV8MA&ixlib=rb-4.1.0&q=80&w=1080" 
                              className="w-full h-full object-cover opacity-80" 
                              alt=""
                            />
                         )}
                         {design.id === 'metallic' && <div className="absolute inset-0 bg-gradient-to-tr from-transparent via-white/10 to-transparent" />}
                      </div>
                      <span className={`font-bold transition-colors ${selectedDesign === design.id ? 'text-app-text-primary' : 'text-app-text-secondary'}`}>
                        {design.name}
                      </span>
                    </div>
                    {selectedDesign === design.id && (
                      <div className="w-6 h-6 rounded-full bg-blue-500 flex items-center justify-center">
                        <Check size={14} className="text-white" strokeWidth={3} />
                      </div>
                    )}
                  </button>
                ))}
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
};
