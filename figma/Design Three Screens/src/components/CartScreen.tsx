import React from 'react';
import { motion } from 'motion/react';
import { Trash2, Minus, Plus, ShoppingBag, ArrowRight } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface CartItem {
  id: string;
  title: string;
  price: number;
  image: string;
  quantity: number;
}

export const CartScreen: React.FC = () => {
  const [items, setItems] = React.useState<CartItem[]>([
    {
      id: '1',
      title: 'iPhone 15 Pro Titanium',
      price: 999,
      image: 'https://images.unsplash.com/photo-1698314439902-70a5966b8cc4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxpcGhvbmUlMjAxNSUyMHBybyUyMHRpdGFuaXVtJTIwZGFyayUyMGJhY2tncm91bmR8ZW58MXx8fHwxNzY5NzY5MTAxfDA&ixlib=rb-4.1.0&q=80&w=1080',
      quantity: 1
    },
    {
      id: '2',
      title: 'Minimalist Dark Sneakers',
      price: 180,
      image: 'https://images.unsplash.com/photo-1763750581767-b367bcd6c117?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjBzbmVha2VycyUyMG1pbmltYWxpc3QlMjBkYXJrfGVufDF8fHx8MTc2OTc2OTEwMXww&ixlib=rb-4.1.0&q=80&w=1080',
      quantity: 1
    }
  ]);

  const total = items.reduce((acc, item) => acc + (item.price * item.quantity), 0);

  const updateQuantity = (id: string, delta: number) => {
    setItems(items.map(item => 
      item.id === id ? { ...item, quantity: Math.max(1, item.quantity + delta) } : item
    ));
  };

  const removeItem = (id: string) => {
    setItems(items.filter(item => item.id !== id));
  };

  return (
    <div className="pb-40 pt-4 px-5 min-h-screen bg-app-bg transition-colors duration-300">
      <header className="mb-8 flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-app-text-primary mb-1 transition-colors">Cart</h1>
          <p className="text-app-text-secondary text-sm transition-colors">{items.length} items ready for checkout</p>
        </div>
        <div className="w-12 h-12 bg-app-surface rounded-2xl flex items-center justify-center text-app-text-secondary border border-app-border transition-colors">
            <ShoppingBag size={20} />
        </div>
      </header>

      <div className="space-y-4">
        {items.map((item) => (
          <motion.div 
            layout
            key={item.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-app-surface p-4 rounded-[24px] border border-app-border flex gap-4 transition-colors"
          >
            <div className="w-24 h-24 rounded-2xl overflow-hidden shrink-0 border border-app-border">
              <ImageWithFallback src={item.image} alt={item.title} className="w-full h-full object-cover" />
            </div>
            
            <div className="flex-1 flex flex-col justify-between py-1">
              <div className="flex justify-between items-start">
                <div>
                  <h3 className="text-[15px] font-bold text-app-text-primary line-clamp-1 transition-colors">{item.title}</h3>
                  <div className="text-lg font-bold text-app-text-primary mt-0.5 transition-colors">${item.price.toLocaleString()}</div>
                </div>
                <button 
                  onClick={() => removeItem(item.id)}
                  className="p-2 text-app-text-secondary hover:text-red-500 transition-colors opacity-50 hover:opacity-100"
                >
                  <Trash2 size={18} />
                </button>
              </div>

              <div className="flex items-center justify-between">
                <div className="flex items-center bg-app-bg rounded-full p-1 border border-app-border transition-colors">
                  <button 
                    onClick={() => updateQuantity(item.id, -1)}
                    className="w-7 h-7 flex items-center justify-center text-app-text-secondary hover:text-app-text-primary transition-colors"
                  >
                    <Minus size={14} />
                  </button>
                  <span className="w-8 text-center text-sm font-bold text-app-text-primary transition-colors">{item.quantity}</span>
                  <button 
                    onClick={() => updateQuantity(item.id, 1)}
                    className="w-7 h-7 flex items-center justify-center text-app-text-secondary hover:text-app-text-primary transition-colors"
                  >
                    <Plus size={14} />
                  </button>
                </div>
              </div>
            </div>
          </motion.div>
        ))}

        {items.length === 0 && (
          <div className="py-20 text-center">
            <div className="w-16 h-16 bg-app-surface rounded-full flex items-center justify-center mx-auto mb-4 border border-app-border transition-colors">
              <ShoppingBag size={32} className="text-app-text-secondary opacity-30 transition-colors" />
            </div>
            <h3 className="text-app-text-secondary font-bold uppercase tracking-widest text-[11px] transition-colors">Your cart is empty</h3>
          </div>
        )}
      </div>

      {items.length > 0 && (
        <div className="fixed bottom-32 left-0 right-0 px-6 max-w-lg mx-auto">
          <div className="bg-app-surface border border-app-border rounded-[28px] p-6 shadow-2xl backdrop-blur-xl transition-colors">
            <div className="flex justify-between items-center mb-6">
              <span className="text-app-text-secondary font-bold uppercase tracking-widest text-[11px] transition-colors">Total Amount</span>
              <span className="text-2xl font-bold text-app-text-primary transition-colors">${total.toLocaleString()}</span>
            </div>
            <button className="w-full bg-app-text-primary text-app-bg font-bold py-4 rounded-2xl flex items-center justify-center gap-2 hover:opacity-90 transition-all active:scale-95 shadow-lg">
              <span>Continue to Checkout</span>
              <ArrowRight size={18} />
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
