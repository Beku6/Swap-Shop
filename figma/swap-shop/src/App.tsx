/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { 
  ArrowLeft, 
  Mail, 
  Eye, 
  EyeOff, 
  Plus, 
  ShieldCheck, 
  ArrowRight,
  AlertCircle
} from 'lucide-react';
import { Screen } from './types';

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('welcome');
  const [showPassword, setShowPassword] = useState(false);

  const navigate = (screen: Screen) => setCurrentScreen(screen);

  return (
    <div className="min-h-screen bg-bg-dark flex justify-center items-center p-4">
      <div className="w-full max-w-[430px] h-[884px] bg-bg-dark rounded-[3rem] shadow-2xl overflow-hidden relative border border-white/5 flex flex-col">
        {/* Decorative Background Elements */}
        <div className="absolute -top-24 -right-24 w-64 h-64 bg-primary/10 blur-[100px] rounded-full pointer-events-none" />
        <div className="absolute top-1/2 -left-32 w-80 h-80 bg-primary/5 blur-[120px] rounded-full pointer-events-none" />

        <AnimatePresence mode="wait">
          {currentScreen === 'welcome' && (
            <motion.div
              key="welcome"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              className="flex-1 flex flex-col p-8"
            >
              <div className="flex justify-end pt-4">
                <button onClick={() => navigate('start-trading')} className="text-slate-400 text-sm font-medium hover:text-white transition-colors">SKIP</button>
              </div>
              <div className="flex-1 flex flex-col justify-center">
                <h1 className="text-white text-6xl font-bold leading-[1.1] tracking-tight mb-6">
                  Welcome to<br />Swap-Shop.
                </h1>
                <div className="w-12 h-1 bg-white/20 mb-8" />
                <p className="text-slate-400 text-xl italic leading-relaxed max-w-[280px]">
                  The destination for premium trades and rare finds.
                </p>
              </div>
              <div className="pb-12 space-y-8">
                <button 
                  onClick={() => navigate('security')}
                  className="w-full h-20 glass rounded-full flex items-center justify-between px-8 group hover:bg-white/5 transition-all"
                >
                  <span className="text-white font-semibold tracking-widest uppercase text-sm">NEXT</span>
                  <div className="w-12 h-12 bg-white rounded-full flex items-center justify-center text-bg-dark group-hover:scale-110 transition-transform">
                    <ArrowRight size={20} />
                  </div>
                </button>
                <div className="flex justify-center gap-3">
                  <div className="w-2 h-2 rounded-full bg-white" />
                  <div className="w-2 h-2 rounded-full bg-white/20" />
                  <div className="w-2 h-2 rounded-full bg-white/20" />
                </div>
              </div>
            </motion.div>
          )}

          {currentScreen === 'security' && (
            <motion.div
              key="security"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              className="flex-1 flex flex-col p-8"
            >
              <header className="pt-4 flex items-center justify-between">
                <button onClick={() => navigate('welcome')} className="p-2 hover:bg-white/5 rounded-full transition-colors">
                  <ArrowLeft size={24} className="text-white" />
                </button>
                <span className="text-primary font-bold tracking-[0.2em] text-xs uppercase">SECURITY</span>
                <div className="w-10" />
              </header>

              <div className="flex-1 flex flex-col items-center justify-center">
                <div className="w-full glass rounded-[3rem] p-8 relative mb-12">
                  <div className="flex flex-col items-center mb-8">
                    <div className="relative mb-4">
                      <img 
                        src="https://picsum.photos/seed/julian/200/200" 
                        alt="Julian Voss" 
                        className="w-24 h-24 rounded-full border-2 border-primary/30 p-1"
                        referrerPolicy="no-referrer"
                      />
                      <div className="absolute bottom-0 right-0 w-6 h-6 bg-primary rounded-full flex items-center justify-center border-2 border-bg-dark">
                        <ShieldCheck size={12} className="text-white" />
                      </div>
                    </div>
                    <h3 className="text-white text-xl font-bold mb-1">Julian Voss</h3>
                    <p className="text-primary text-[10px] font-bold tracking-widest uppercase">VERIFIED ELITE MEMBER</p>
                  </div>

                  <div className="space-y-4">
                    <div className="flex justify-between items-end">
                      <span className="text-slate-400 text-[10px] uppercase font-bold tracking-wider">Swap Escrow Protection</span>
                      <span className="text-primary text-[10px] uppercase font-bold tracking-wider">SECURED</span>
                    </div>
                    <div className="h-2 w-full bg-white/5 rounded-full overflow-hidden">
                      <motion.div 
                        initial={{ width: 0 }}
                        animate={{ width: '100%' }}
                        transition={{ duration: 1.5, ease: "easeOut" }}
                        className="h-full bg-primary"
                      />
                    </div>
                    <div className="flex items-center justify-center gap-2 opacity-40">
                      <ShieldCheck size={12} />
                      <span className="text-[8px] uppercase font-bold tracking-widest">TRANSACTION MONITORED BY SWAP-SHOP</span>
                    </div>
                  </div>
                </div>

                <div className="text-center space-y-4 px-4">
                  <h2 className="text-white text-4xl font-bold leading-tight">Protected.<br />Secure. Verified.</h2>
                  <p className="text-slate-400 text-sm leading-relaxed">
                    Every transaction is secured via Swap Escrow. Funds and items stay safe until both sides confirm.
                  </p>
                </div>
              </div>

              <div className="pb-12 space-y-8">
                <div className="glass rounded-[2.5rem] p-8 flex flex-col items-center gap-6">
                  <div className="flex gap-3">
                    <div className="w-8 h-1 rounded-full bg-white/20" />
                    <div className="w-8 h-1 rounded-full bg-primary" />
                    <div className="w-8 h-1 rounded-full bg-white/20" />
                  </div>
                  <button 
                    onClick={() => navigate('start-trading')}
                    className="w-full h-16 bg-primary text-white rounded-full font-bold text-lg flex items-center justify-center gap-2 hover:opacity-90 transition-opacity"
                  >
                    Continue <ArrowRight size={20} />
                  </button>
                  <span className="text-slate-500 text-[10px] uppercase font-bold tracking-widest">STEP 2 OF 3</span>
                </div>
              </div>
            </motion.div>
          )}

          {currentScreen === 'start-trading' && (
            <motion.div
              key="start-trading"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              className="flex-1 flex flex-col p-8"
            >
              <div className="flex justify-end pt-4">
                <button onClick={() => navigate('welcome')} className="text-slate-400 text-sm font-medium hover:text-white transition-colors">Skip</button>
              </div>

              <div className="flex-1 flex flex-col items-center justify-center">
                <div className="relative w-full max-w-[280px] aspect-square flex items-center justify-center mb-12">
                  <div className="absolute inset-0 bg-primary/20 blur-[80px] rounded-full" />
                  <div className="relative z-10 w-full p-8 rounded-[2rem] glass flex flex-col items-center gap-6">
                    <div className="w-16 h-16 rounded-full bg-white flex items-center justify-center shadow-xl">
                      <Plus size={32} className="text-bg-dark" strokeWidth={3} />
                    </div>
                    <div className="space-y-2 w-full">
                      <div className="h-2 w-3/4 bg-white/20 rounded-full mx-auto" />
                      <div className="h-2 w-1/2 bg-white/10 rounded-full mx-auto" />
                    </div>
                  </div>
                </div>

                <div className="text-center space-y-4">
                  <h1 className="text-white text-4xl font-bold tracking-tight">Start trading.</h1>
                  <p className="text-slate-400 text-lg leading-relaxed max-w-[260px] mx-auto">
                    Join the community. List your first item in minutes.
                  </p>
                </div>
              </div>

              <div className="pb-12 pt-8 flex flex-col items-center gap-8 glass rounded-t-[3rem] -mx-8 px-8">
                <div className="flex gap-3">
                  <div className="w-1.5 h-1.5 rounded-full bg-white/20" />
                  <div className="w-1.5 h-1.5 rounded-full bg-white/20" />
                  <div className="w-8 h-1.5 rounded-full bg-white" />
                </div>
                <div className="w-full space-y-4">
                  <button 
                    onClick={() => navigate('register')}
                    className="w-full h-16 bg-white text-bg-dark rounded-full font-bold text-lg hover:bg-slate-200 transition-colors"
                  >
                    Create Account
                  </button>
                  <button 
                    onClick={() => navigate('login')}
                    className="w-full h-16 bg-transparent border border-white/30 text-white rounded-full font-bold text-lg hover:bg-white/5 transition-colors"
                  >
                    Log In
                  </button>
                </div>
                <div className="w-32 h-1.5 bg-white/20 rounded-full" />
              </div>
            </motion.div>
          )}

          {currentScreen === 'login' && (
            <motion.div
              key="login"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="flex-1 flex flex-col p-8"
            >
              <header className="pt-4 flex items-center justify-between">
                <button onClick={() => navigate('start-trading')} className="p-2 hover:bg-white/5 rounded-full transition-colors">
                  <ArrowLeft size={24} className="text-white" />
                </button>
                <span className="text-white font-bold text-lg">Swap-Shop</span>
                <div className="w-10" />
              </header>

              <div className="pt-12 pb-8">
                <h1 className="text-white text-4xl font-bold leading-tight mb-2">Access your account.</h1>
                <p className="text-slate-400 text-lg">Continue where you left off.</p>
              </div>

              <div className="flex-1">
                <div className="glass rounded-[2rem] p-6 space-y-6">
                  <div className="space-y-2">
                    <label className="text-xs font-bold text-slate-500 uppercase tracking-widest ml-1">Email</label>
                    <div className="relative">
                      <input 
                        type="email" 
                        placeholder="name@example.com"
                        className="w-full h-14 bg-white/5 border border-white/10 rounded-xl px-4 text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all placeholder:text-slate-600"
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <label className="text-xs font-bold text-slate-500 uppercase tracking-widest ml-1">Password</label>
                    <div className="relative">
                      <input 
                        type={showPassword ? "text" : "password"} 
                        placeholder="Enter your password"
                        className="w-full h-14 bg-white/5 border border-white/10 rounded-xl px-4 pr-12 text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all placeholder:text-slate-600"
                      />
                      <button 
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-500 hover:text-white transition-colors"
                      >
                        {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                      </button>
                    </div>
                    <div className="flex justify-end">
                      <button onClick={() => navigate('reset-password')} className="text-primary text-sm font-semibold hover:underline">Forgot password?</button>
                    </div>
                  </div>
                </div>
              </div>

              <div className="pb-12 space-y-4">
                <button className="w-full h-16 bg-white text-bg-dark rounded-full font-bold text-lg hover:bg-slate-200 transition-colors">
                  Sign In
                </button>
                <button className="w-full h-16 bg-transparent border border-white/10 rounded-full flex items-center justify-center gap-3 hover:bg-white/5 transition-colors">
                  <svg className="w-5 h-5" viewBox="0 0 24 24">
                    <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4" />
                    <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" />
                    <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05" />
                    <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" />
                  </svg>
                  <span className="font-semibold">Sign in with Google</span>
                </button>
                <div className="text-center pt-4">
                  <p className="text-slate-500 text-sm">
                    Don't have an account? <button onClick={() => navigate('register')} className="text-primary font-bold hover:underline">Create one</button>
                  </p>
                </div>
              </div>
            </motion.div>
          )}

          {currentScreen === 'register' && (
            <motion.div
              key="register"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="flex-1 flex flex-col p-8"
            >
              <header className="pt-4 flex items-center">
                <button onClick={() => navigate('start-trading')} className="p-2 hover:bg-white/5 rounded-full transition-colors">
                  <ArrowLeft size={24} className="text-white" />
                </button>
              </header>

              <div className="pt-8 pb-6">
                <h1 className="text-white text-4xl font-bold leading-tight mb-2">Create your profile.</h1>
                <p className="text-slate-400 text-lg">Start buying, selling, and swapping.</p>
              </div>

              <div className="flex-1">
                <div className="glass rounded-[2rem] p-6 space-y-5">
                  <div className="space-y-2">
                    <label className="text-xs font-bold text-slate-500 uppercase tracking-widest ml-1">Email</label>
                    <input 
                      type="email" 
                      placeholder="name@example.com"
                      className="w-full h-14 bg-white/5 border border-white/10 rounded-xl px-4 text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all placeholder:text-slate-600"
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="text-xs font-bold text-slate-500 uppercase tracking-widest ml-1">Password</label>
                    <div className="relative">
                      <input 
                        type={showPassword ? "text" : "password"} 
                        placeholder="Enter your password"
                        className="w-full h-14 bg-white/5 border border-white/10 rounded-xl px-4 pr-12 text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all placeholder:text-slate-600"
                      />
                      <button 
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-500 hover:text-white transition-colors"
                      >
                        {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                      </button>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <label className="text-xs font-bold text-slate-500 uppercase tracking-widest ml-1">Confirm Password</label>
                    <div className="relative">
                      <input 
                        type={showPassword ? "text" : "password"} 
                        placeholder="Repeat password"
                        className="w-full h-14 bg-white/5 border border-red-500/30 rounded-xl px-4 pr-12 text-white focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all placeholder:text-slate-600"
                      />
                      <button 
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-500 hover:text-white transition-colors"
                      >
                        {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                      </button>
                    </div>
                    <p className="text-red-500/80 text-[10px] font-bold tracking-widest uppercase mt-1 ml-1 flex items-center gap-1">
                      <AlertCircle size={10} />
                      Passwords do not match
                    </p>
                  </div>
                </div>
              </div>

              <div className="pb-12 space-y-4">
                <button className="w-full h-16 bg-white text-bg-dark rounded-full font-bold text-lg hover:bg-slate-200 transition-colors">
                  Create Account
                </button>
                <button className="w-full h-16 bg-transparent border border-white/10 rounded-full flex items-center justify-center gap-3 hover:bg-white/5 transition-colors">
                  <svg className="w-5 h-5" viewBox="0 0 24 24">
                    <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4" />
                    <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" />
                    <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05" />
                    <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" />
                  </svg>
                  <span className="font-semibold">Sign up with Google</span>
                </button>
                <div className="text-center pt-2">
                  <p className="text-slate-500 text-sm">
                    Already have an account? <button onClick={() => navigate('login')} className="text-primary font-bold hover:underline">Log in</button>
                  </p>
                </div>
              </div>
            </motion.div>
          )}

          {currentScreen === 'reset-password' && (
            <motion.div
              key="reset-password"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="flex-1 flex flex-col p-8"
            >
              <header className="pt-4">
                <button onClick={() => navigate('login')} className="size-12 rounded-full glass flex items-center justify-center hover:bg-white/10 transition-colors">
                  <ArrowLeft size={24} className="text-white" />
                </button>
              </header>

              <div className="pt-12 pb-12">
                <h1 className="text-white text-4xl font-bold leading-tight mb-4">Reset access.</h1>
                <p className="text-slate-400 text-lg max-w-[280px]">
                  Enter your email to receive reset instructions.
                </p>
              </div>

              <div className="flex-1 flex flex-col">
                <div className="space-y-2">
                  <label className="text-xs font-bold text-slate-500 uppercase tracking-widest ml-1">Email Address</label>
                  <div className="relative group">
                    <input 
                      type="email" 
                      placeholder="lux@swapshop.com"
                      className="w-full h-16 glass rounded-2xl px-6 text-white text-lg focus:ring-2 focus:ring-primary/20 outline-none transition-all placeholder:text-slate-700"
                    />
                    <div className="absolute right-6 top-1/2 -translate-y-1/2 text-primary opacity-40 group-focus-within:opacity-100 transition-opacity">
                      <Mail size={24} />
                    </div>
                  </div>
                </div>
              </div>

              <div className="pb-12 space-y-6">
                <button className="w-full h-16 bg-white text-bg-dark rounded-full font-bold text-lg hover:bg-slate-200 transition-colors shadow-xl shadow-primary/5">
                  Send Instructions
                </button>
                <button 
                  onClick={() => navigate('login')}
                  className="w-full flex items-center justify-center gap-2 text-slate-400 hover:text-white transition-colors font-medium"
                >
                  <ArrowLeft size={16} /> Back to Login
                </button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
