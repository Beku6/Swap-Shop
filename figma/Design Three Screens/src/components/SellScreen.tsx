import React from 'react';
import { Camera, Plus, Repeat, DollarSign, ChevronRight, X } from 'lucide-react';

export const SellScreen: React.FC = () => {
  const [sellMode, setSellMode] = React.useState<'price' | 'barter'>('price');

  return (
    <div className="pb-32 pt-4 px-5 bg-app-bg transition-colors duration-300 min-h-screen">
      <header className="mb-8">
        <h1 className="text-3xl font-bold tracking-tight text-app-text-primary mb-1 transition-colors">List Item</h1>
        <p className="text-app-text-secondary text-sm transition-colors">Create a new listing for the community</p>
      </header>

      <div className="space-y-8">
        {/* Photo Upload */}
        <section>
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-[11px] font-bold text-app-text-secondary uppercase tracking-[0.1em] transition-colors">Product Photos</h3>
            <span className="text-[11px] text-app-text-secondary transition-colors">0 / 5</span>
          </div>
          <div className="flex gap-3 overflow-x-auto no-scrollbar pb-2">
            <button className="shrink-0 w-32 aspect-square bg-app-surface border-2 border-dashed border-app-border rounded-3xl flex flex-col items-center justify-center gap-2 text-app-text-secondary opacity-50 hover:opacity-100 transition-all group active:scale-95">
              <Camera size={24} className="group-hover:scale-110 transition-transform" />
              <span className="text-[10px] font-bold uppercase tracking-wider">Add Photo</span>
            </button>
            {[1, 2].map((i) => (
              <div key={i} className="shrink-0 w-32 aspect-square bg-app-surface rounded-3xl border border-app-border transition-colors" />
            ))}
          </div>
        </section>

        {/* Basic Info */}
        <section className="space-y-4">
          <div>
            <label className="text-[11px] font-bold text-app-text-secondary uppercase tracking-[0.1em] mb-2 block transition-colors">Item Title</label>
            <input 
              type="text" 
              placeholder="e.g. Vintage Leica Camera"
              className="w-full bg-app-surface border border-app-border rounded-2xl py-4 px-5 text-app-text-primary placeholder:text-app-text-secondary/30 focus:ring-1 focus:ring-app-text-primary/10 transition-all text-[15px]"
            />
          </div>

          <div>
            <label className="text-[11px] font-bold text-app-text-secondary uppercase tracking-[0.1em] mb-2 block transition-colors">Category</label>
            <button className="w-full bg-app-surface border border-app-border rounded-2xl py-4 px-5 flex justify-between items-center text-app-text-secondary hover:text-app-text-primary transition-all">
              <span className="text-[15px] font-medium">Select a category</span>
              <ChevronRight size={18} />
            </button>
          </div>
        </section>

        {/* Pricing Strategy */}
        <section>
          <label className="text-[11px] font-bold text-app-text-secondary uppercase tracking-[0.1em] mb-3 block transition-colors">Exchange Type</label>
          <div className="p-1 bg-app-surface border border-app-border rounded-2xl flex gap-1 mb-4 transition-colors">
            <button 
              onClick={() => setSellMode('price')}
              className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-xl transition-all ${
                sellMode === 'price' ? 'bg-app-bg text-app-text-primary shadow-sm border border-app-border' : 'text-app-text-secondary'
              }`}
            >
              <DollarSign size={16} />
              <span className="text-[13px] font-bold">Fixed Price</span>
            </button>
            <button 
              onClick={() => setSellMode('barter')}
              className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-xl transition-all ${
                sellMode === 'barter' ? 'bg-app-bg text-app-text-primary shadow-sm border border-app-border' : 'text-app-text-secondary'
              }`}
            >
              <Repeat size={16} />
              <span className="text-[13px] font-bold">Barter</span>
            </button>
          </div>

          {sellMode === 'price' ? (
             <div className="relative">
                <span className="absolute left-5 top-1/2 -translate-y-1/2 text-app-text-secondary font-bold text-lg opacity-30">$</span>
                <input 
                  type="number" 
                  placeholder="0.00"
                  className="w-full bg-app-surface border border-app-border rounded-2xl py-4 pl-10 pr-5 text-app-text-primary placeholder:text-app-text-secondary/30 focus:ring-1 focus:ring-app-text-primary/10 transition-all text-xl font-bold"
                />
             </div>
          ) : (
            <textarea 
              placeholder="What kind of items are you looking for in return?"
              className="w-full bg-app-surface border border-app-border rounded-2xl py-4 px-5 text-app-text-primary placeholder:text-app-text-secondary/30 focus:ring-1 focus:ring-app-text-primary/10 transition-all text-[15px] min-h-[100px] resize-none"
            />
          )}
        </section>

        {/* Publish Button */}
        <button className="w-full bg-app-text-primary text-app-bg font-bold py-4 rounded-2xl flex items-center justify-center gap-2 hover:opacity-90 transition-all active:scale-95 shadow-lg">
           <Plus size={20} />
           <span>Publish Listing</span>
        </button>
      </div>
    </div>
  );
};
