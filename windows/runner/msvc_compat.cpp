#include <windows.h>
#include <stdlib.h>
#include <string.h>

extern "C" {
    // 1. _Avx2WmemEnabled
    bool _Avx2WmemEnabled = false;

    // 2. _Thrd_sleep_for
    struct _Thrd_duration {
        __int64 _Sec;
        __int64 _Nanos;
    };
    int __cdecl _Thrd_sleep_for(const _Thrd_duration* _Dur) {
        if (_Dur) {
            __int64 ms = _Dur->_Sec * 1000 + _Dur->_Nanos / 1000000;
            if (ms < 0) ms = 0;
            Sleep((DWORD)ms);
        }
        return 0;
    }

    // 3. _Cnd_timedwait_for_unchecked
    int __cdecl _Cnd_timedwait_for_unchecked(void* _Cnd, void* _Mtx, const _Thrd_duration* _Dur) {
        if (!_Cnd || !_Mtx) return 1;
        CONDITION_VARIABLE* cv = reinterpret_cast<CONDITION_VARIABLE*>(_Cnd);
        CRITICAL_SECTION* cs = reinterpret_cast<CRITICAL_SECTION*>(_Mtx);
        DWORD ms = INFINITE;
        if (_Dur) {
            __int64 calculated = _Dur->_Sec * 1000 + _Dur->_Nanos / 1000000;
            if (calculated < 0) calculated = 0;
            ms = static_cast<DWORD>(calculated);
        }
        if (SleepConditionVariableCS(cv, cs, ms)) {
            return 0; // success
        } else {
            if (GetLastError() == ERROR_TIMEOUT) {
                return 2; // timed out
            }
            return 1; // error
        }
    }

    // 4. __std_init_once_link_alternate_names_and_abort
    void __cdecl __std_init_once_link_alternate_names_and_abort() {
        abort();
    }

    // 5. __std_find_trivial_8
    const void* __cdecl __std_find_trivial_8(const void* _First, const void* _Last, unsigned __int64 _Val) {
        const unsigned __int64* first = static_cast<const unsigned __int64*>(_First);
        const unsigned __int64* last = static_cast<const unsigned __int64*>(_Last);
        while (first < last) {
            if (*first == _Val) return first;
            ++first;
        }
        return last;
    }

    // 6. __std_find_trivial_4
    const void* __cdecl __std_find_trivial_4(const void* _First, const void* _Last, unsigned int _Val) {
        const unsigned int* first = static_cast<const unsigned int*>(_First);
        const unsigned int* last = static_cast<const unsigned int*>(_Last);
        while (first < last) {
            if (*first == _Val) return first;
            ++first;
        }
        return last;
    }

    // 7. __std_find_trivial_2
    const void* __cdecl __std_find_trivial_2(const void* _First, const void* _Last, unsigned short _Val) {
        const unsigned short* first = static_cast<const unsigned short*>(_First);
        const unsigned short* last = static_cast<const unsigned short*>(_Last);
        while (first < last) {
            if (*first == _Val) return first;
            ++first;
        }
        return last;
    }

    // 8. __std_find_trivial_1
    const void* __cdecl __std_find_trivial_1(const void* _First, const void* _Last, unsigned char _Val) {
        const unsigned char* first = static_cast<const unsigned char*>(_First);
        const unsigned char* last = static_cast<const unsigned char*>(_Last);
        while (first < last) {
            if (*first == _Val) return first;
            ++first;
        }
        return last;
    }

    // 9. __std_find_last_trivial_1
    const void* __cdecl __std_find_last_trivial_1(const void* _First, const void* _Last, unsigned char _Val) {
        const unsigned char* first = static_cast<const unsigned char*>(_First);
        const unsigned char* last = static_cast<const unsigned char*>(_Last);
        const unsigned char* it = last;
        while (it > first) {
            --it;
            if (*it == _Val) return it;
        }
        return last;
    }

    // 10. __std_find_end_1
    const void* __cdecl __std_find_end_1(const void* _First1, const void* _Last1, const void* _First2, const void* _Last2) {
        const char* f1 = static_cast<const char*>(_First1);
        const char* l1 = static_cast<const char*>(_Last1);
        const char* f2 = static_cast<const char*>(_First2);
        const char* l2 = static_cast<const char*>(_Last2);
        size_t len1 = l1 - f1;
        size_t len2 = l2 - f2;
        if (len2 == 0) return l1;
        if (len1 < len2) return l1;
        for (size_t i = len1 - len2 + 1; i > 0; --i) {
            if (memcmp(f1 + (i - 1), f2, len2) == 0) {
                return f1 + (i - 1);
            }
        }
        return l1;
    }

    // 11. __std_max_element_d
    const double* __cdecl __std_max_element_d(const double* _First, const double* _Last) {
        if (_First == _Last) return _Last;
        const double* max_elem = _First;
        for (const double* cur = _First + 1; cur < _Last; ++cur) {
            if (*max_elem < *cur) {
                max_elem = cur;
            }
        }
        return max_elem;
    }

    // 12. __std_min_element_8
    const void* __cdecl __std_min_element_8(const void* _First, const void* _Last) {
        if (_First == _Last) return _Last;
        const __int64* first = static_cast<const __int64*>(_First);
        const __int64* last = static_cast<const __int64*>(_Last);
        const __int64* min_elem = first;
        for (const __int64* cur = first + 1; cur < last; ++cur) {
            if (*cur < *min_elem) {
                min_elem = cur;
            }
        }
        return min_elem;
    }

    // 13. __std_min_8i
    struct __std_min_8i_result {
        __int64 _Val;
        unsigned __int64 _Idx;
    };
    __std_min_8i_result __cdecl __std_min_8i(const void* _First, unsigned __int64 _Count) {
        __std_min_8i_result res = { 0, 0 };
        if (_Count == 0 || !_First) return res;
        const __int64* ptr = static_cast<const __int64*>(_First);
        res._Val = ptr[0];
        res._Idx = 0;
        for (unsigned __int64 i = 1; i < _Count; ++i) {
            if (ptr[i] < res._Val) {
                res._Val = ptr[i];
                res._Idx = i;
            }
        }
        return res;
    }

    // 14. __std_search_1
    const void* __cdecl __std_search_1(const void* _First1, const void* _Last1, const void* _First2, const void* _Last2) {
        const char* f1 = static_cast<const char*>(_First1);
        const char* l1 = static_cast<const char*>(_Last1);
        const char* f2 = static_cast<const char*>(_First2);
        const char* l2 = static_cast<const char*>(_Last2);
        size_t len1 = l1 - f1;
        size_t len2 = l2 - f2;
        if (len2 == 0) return f1;
        if (len1 < len2) return l1;
        for (size_t i = 0; i <= len1 - len2; ++i) {
            if (memcmp(f1 + i, f2, len2) == 0) {
                return f1 + i;
            }
        }
        return l1;
    }

    // 15. __std_remove_8
    void* __cdecl __std_remove_8(void* _First, void* _Last, unsigned __int64 _Val) {
        unsigned __int64* first = static_cast<unsigned __int64*>(_First);
        unsigned __int64* last = static_cast<unsigned __int64*>(_Last);
        unsigned __int64* result = first;
        while (first != last) {
            if (*first != _Val) {
                *result = *first;
                ++result;
            }
            ++first;
        }
        return result;
    }

    // 16. __std_find_first_of_trivial_pos_1
    unsigned __int64 __cdecl __std_find_first_of_trivial_pos_1(const char* _First1, unsigned __int64 _Count1, const char* _First2, unsigned __int64 _Count2) {
        for (unsigned __int64 i = 0; i < _Count1; ++i) {
            for (unsigned __int64 j = 0; j < _Count2; ++j) {
                if (_First1[i] == _First2[j]) {
                    return i;
                }
            }
        }
        return _Count1;
    }

    // 17. __std_find_last_of_trivial_pos_1
    unsigned __int64 __cdecl __std_find_last_of_trivial_pos_1(const char* _First1, unsigned __int64 _Count1, const char* _First2, unsigned __int64 _Count2) {
        for (unsigned __int64 i = _Count1; i > 0; --i) {
            for (unsigned __int64 j = 0; j < _Count2; ++j) {
                if (_First1[i - 1] == _First2[j]) {
                    return i - 1;
                }
            }
        }
        return _Count1;
    }

    // 18. bad_cast shims
    void* __cdecl MockBadCastCtor(void* p, char const*) { return p; }
    void* (*MockBadCastCtorPtr)(void*, char const*) = &MockBadCastCtor;
    void __cdecl MockBadCastDoraise(void*) { abort(); }
}

#pragma comment(linker, "/alternatename:__imp_??0bad_cast@std@@QEAA@PEBD@Z=MockBadCastCtorPtr")
#pragma comment(linker, "/alternatename:?_Doraise@bad_cast@std@@MEBAXXZ=MockBadCastDoraise")
