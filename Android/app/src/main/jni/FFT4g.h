#include <iostream>

class FFT4g {
public:
    FFT4g(int n);
    virtual ~FFT4g();
    void rdft(int isgn, double a[]);
private:
    int ip[];
    double w[];
    int n;
    void makewt(int nw);
    void makect(int nc, double c[], int nw);
    void bitrv2(int n, double a[]);
    void rftfsub(double a[], int nc, double c[], int nw);
    void rftbsub(double a[], int nc, double c[], int nw);
    void cftfsub(double a[]);
    void cftbsub(double a[]);
    void cft1st(double a[]);
    void cftmdl(int l, double a[]);
};
