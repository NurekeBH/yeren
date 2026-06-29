'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

export default function ProviderHome() {
  const router = useRouter();
  useEffect(() => {
    router.replace('/provider/courses');
  }, [router]);
  return null;
}
