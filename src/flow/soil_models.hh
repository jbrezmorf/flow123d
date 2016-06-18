/* 
 * File:   hydro_functions.hh
 * Author: jb
 *
 * Created on May 17, 2010, 1:52 PM
 */

#ifndef _HYDRO_FUNCTIONS_HH
#define	_HYDRO_FUNCTIONS_HH

#include <algorithm>
#include <cmath>



// todo: 
// objekt por SoilModel - jedna sada primarnich i pomocnych parametru
// konzistentni hydrologicke funkce
//
// potreboval bych mit vice modelu, z orezavanim i bez nej,
// orezavani zpusobuje velke residuum v miste nespojitosti derivace saturace

// problem - jak pouzit funktory, FADBAD, aproximace a 
// inverzi (inverze tlak v zav. na vlhkosti)
//
// podrobnejsi vyzkum ohledne hydrologickych funkci
// vodivost vyplyva s kapilarnich modelu (jak presne?)
// co vlhkost?

/**
 * One of possibly more classes specifying dependence of the relative conductivity and the relative water content on the
 * pressure head. These functions (@p conductivity and @p water_content, respectively) are templates to allow evaluation of
 * the derivatives through fadbad lib.
 */

struct SoilData {
    double  n;              // power parameter
    double  alpha;           // pressure head scaling
    double  Qr;             // residual water content
    double  Qs;             // saturated water content
    double  cut_fraction;   // in (0,1), fraction of relative Q where to cut and rescale the retention curve
    double  Ks;             // saturated conductivity
//    double  Kk;             // conductivity at the cut point
};

class SoilModel_VanGenuchten {
public:
    SoilModel_VanGenuchten();
    SoilModel_VanGenuchten(SoilData soil);

    void reset(SoilData soil);

    template <class T>
    T conductivity(const T &h) const;

    template <class T>
    T water_content(const T &h) const;

protected:

    template <class T>
    inline T Q_rel(const T &h) const
    {
        return  pow( 1 + pow(-soil_param_.alpha * h, soil_param_.n), -m);
    }

    template <class T>
    inline T Q_rel_inv(const T &q) const
    {
        return  -pow( pow( q, -1/m ) -1, 1/soil_param_.n)/soil_param_.alpha;
    }


    // input parameters
    SoilData  soil_param_;

    // conductivity parameters
    const double Bpar;
    const double Ppar;
    const double K_lower_limit;

    // aux values
    double m;
    double Qs_nc;       // saturated value of continuation of cut water content function


    double FFQr, FFQs;
    double Hs;

};

SoilModel_VanGenuchten::SoilModel_VanGenuchten()
:  Bpar(0.5), Ppar(2), K_lower_limit(1.0E-20)
{

}


SoilModel_VanGenuchten::SoilModel_VanGenuchten(SoilData soil)
:  SoilModel_VanGenuchten()
{
    reset(soil);
}


void SoilModel_VanGenuchten::reset(SoilData soil)
{
    // check soil parameters
    ASSERT_LT_DBG( soil.cut_fraction, 1.0);
    ASSERT_GT_DBG( soil.cut_fraction, 0.0);
    soil_param_ = soil;

    m = 1-1/soil_param_.n;
    // soil_param_.cut_fraction = (Qs -Qr)/(Qnc - Qr)
    Qs_nc = (soil_param_.Qs - soil_param_.Qr)/soil_param_.cut_fraction  + soil_param_.Qr;

    // conductivity internal scaling
    FFQr = 1.0;   // pow(1 - pow(Qeer,1/m),m);
    double Qs_relative = soil_param_.cut_fraction;
    FFQs = pow(1 - pow(Qs_relative, 1/m),m);


    Hs = Q_rel_inv(soil_param_.cut_fraction);
    //std::cout << "Hs : " << Hs << " qs: " << soil_param_.Qs << " qsnc: " << Qs_nc << std::endl;

}


// pri generovani grafu jsem zjistil ze originalni vzorecek pro
// vodivost pres theta je numericky nestabilni pro tlaky blizke
// nule, zejmena pro velka n
// tento vzorec je stabilni:
//
/// k(h)=t(h)**(0.5)* (1- ((h)**n/(1+(h)**n)) **m)**2

template <class T>
T SoilModel_VanGenuchten::conductivity(const T& h) const
{
    T Kr,Q, Q_unscaled, Q_cut_unscaled, FFQ;

      if (h < Hs) {
            Q_unscaled = Q_rel(h);
            Q_cut_unscaled = Q_unscaled / soil_param_.cut_fraction;
            FFQ = pow(1 - pow(Q_unscaled,1/m),m);
            Kr = soil_param_.Ks * pow(Q_cut_unscaled,Bpar)*pow((FFQr - FFQ)/(FFQr - FFQs),Ppar);
    }
    else Kr = soil_param_.Ks;

    if (Kr < K_lower_limit) return K_lower_limit;
    else return Kr;
}


template <class T>
T SoilModel_VanGenuchten::water_content(const T& h) const
{
    if (h < Hs) return soil_param_.Qr + (Qs_nc - soil_param_.Qr) *Q_rel(h);
    else return soil_param_.Qs;
}


class SoilModel_Irmay : public SoilModel_VanGenuchten {
public:
    SoilModel_Irmay();
    SoilModel_Irmay(SoilData soil);

    template <class T>
    T conductivity(const T &h) const;

private:
    // conductivity parameters
    const double Ppar;
    const double K_lower_limit;
};

SoilModel_Irmay::SoilModel_Irmay()
:  Ppar(3), K_lower_limit(1.0E-20)
{}


SoilModel_Irmay::SoilModel_Irmay(SoilData soil)
:  SoilModel_Irmay()
{
    reset(soil);
}




template <class T>
T SoilModel_Irmay::conductivity(const T& h) const
{
    T Kr;

    if (h < Hs) {
        T Q = this->Q_rel(h);
        Kr = soil_param_.Ks * pow(Q, 3);
    }
    else Kr = soil_param_.Ks;

    if (Kr < K_lower_limit) return K_lower_limit;
    else return Kr;
}






/*

//FK-------------------------------------------------------------
template <class T>
class FK	//FK - hydraulic conductivity function
{
private:
// function parameters
static const double	Bpar;   // = 0.5;
static const double	PPar;   // = 2;

HydrologyParams par;

// auxiliary parameters
double Qa,Qm,Qk,m,Hr,Hk,Hs,C1Qee,C2Qee,Qeer,Qees,Qeek;
public:
    FK(const HydrologyParams &par);
    T operator()(const T&  h);
};

template <class T> const double FK<T>::Bpar =0.5;
template <class T> const double FK<T>::PPar =2;

template <class T>
FK<T> :: FK(const HydrologyParams &par)
: par(par)
{

	m = 1-1/par.n;

        Qa=par.Qr;
        Qm=par.Qs / par.cut_fraction;
        //Qk=0.99 * par.Qs;
        Qk=par.Qs;
        C1Qee = 1/(Qm - Qa);
        C2Qee = -Qa/(Qm - Qa);
//    if (par.cut_fraction >0.9999) {
//        Hr=-1000;
//        Hk=Hs=0;
//        return;
//    }
                                                        // fraction =1
        Qees = C1Qee * par.Qs + C2Qee;                  // 1
        Qeek = min(C1Qee * Qk + C2Qee, Qees);           // 1
        Qeer = min(C1Qee * par.Qr + C2Qee, Qeek);       // 0

        Hr = -1/par.alfa*pow(pow(Qeer,-1/m)-1,1/par.n); //
        Hs = -1/par.alfa*pow(pow(Qees,-1/m)-1,1/par.n);
        Hk = -1/par.alfa*pow(pow(Qeek,-1/m)-1,1/par.n);

        cout << "K: Hr, Hs, Hk:" << Hr << " " << Hs << " " << Hk << endl;
}

template <class T>
T FK<T> :: operator()(const T& h)
{
    T Kr,FFQr,FFQ,FFQk,Qee,Qe,Qek,C1Qe,C2Qe,Q;

    if (h < Hr) return par.Ks*(1E-200);      // numericaly zero Kr
    else 
      if (h < Hk) {
            Q = Qa + (Qm - Qa)*pow((1 + pow(-par.alfa*h,par.n)),-m);
            Qee = C1Qee*Q + C2Qee;
            FFQr = pow(1 - pow(Qeer,1/m),m);
            FFQ = pow(1 - pow(Qee,1/m),m);
            FFQk = pow(1 - pow(Qeek,1/m),m);
            C1Qe = 1/(par.Qs - par.Qr);
            C2Qe = -par.Qr/(par.Qs - par.Qr);
            Qe = C1Qe*Q + C2Qe;
            Qek = C1Qe*Qk + C2Qe;
            Kr = pow(Qe/Qek,Bpar)*pow((FFQr - FFQ)/(FFQr - FFQk),PPar) * par.Kk/par.Ks;
            return ( max<T>(par.Ks*Kr,par.Ks*(1E-10)) );
    }
    else if(h <= Hs)
    {
         Kr = (1-par.Kk/par.Ks)/(Hs-Hk)*(h-Hs) + 1;
         return ( par.Ks*Kr );
    }
    else return par.Ks;
}


//FQ--------------------------------------------------------------
template <class T>
class FQ	//FQ - water saturation function
{
HydrologyParams par;
// auxiliary parameters
double  m, Qeer,Qees,Hr,Hs, Qa, Qm;
public:
    FQ(const HydrologyParams &par);
    T operator()(const T&  h);
};

template <class T>
FQ<T>::FQ(const HydrologyParams &par)
: par(par)
{
    m = 1 - 1 / par.n;

//    if (par.cut_fraction >0.9999) {
//        Hr=-1000;
//        Hs=0;
//        return;
//    }
    Qm=par.Qs / par.cut_fraction;
    Qa=par.Qr;

    Qeer = (par.Qr - Qa)/ (Qm - Qa);
    Qees = (par.Qs - Qa)/ (Qm - Qa);
    Hr = -1 / par.alfa * pow( pow(Qeer,-1/m)-1, 1/par.n);
    Hs = -1 / par.alfa * pow( pow(Qees,-1/m)-1, 1/par.n);

    cout << "Q: Hr, Hs:" << Hr << " " << Hs << " " << endl;
}


template <class T>
T FQ<T>::operator()(const T& h)
{
    T  Qee;

    if (h < Hr) return par.Qr;
    else if (h < Hs) {
        Qee = pow( 1 + pow(-par.alfa * h, par.n), -m);
        return Qa + (Qm - Qa) * Qee;
    }
    else return par.Qs;

}

//FC--------------------------------------------------------------
template <class T>
class FC	//FC - water capacity function FQ derivative
{
HydrologyParams par;
// auxiliary parameters
double  m, C1Qee,C2Qee,Qeer,Qees,Hr,Hs, Qa, Qm;
public:
    FC(const HydrologyParams &par);
    T operator()(const T&  h);
};

template <class T>
FC<T>::FC(const HydrologyParams &par)
: par(par)
{
    m = 1 - 1 / par.n;
    Qm=par.Qs / par.cut_fraction;
    Qa=par.Qr;

    C1Qee = 1/(Qm - Qa);
    C2Qee = -Qa/(Qm - Qa);
    Qeer = C1Qee * par.Qr + C2Qee;
    Qees = C1Qee * par.Qs + C2Qee;
    Hr = -1 / par.alfa * pow( pow(Qeer,-1/m)-1, 1/par.n);
    Hs = -1 / par.alfa * pow( pow(Qees,-1/m)-1, 1/par.n);
}


template <class T>
T FC<T>::operator()(const T& h)
{
    T  C1;

    if (h <= Hr)
        return 0.0;
    else if ( h < Hs ) {
        C1=pow( 1 + pow( -par.alfa * h, par.n), -m-1);
        return (Qm - Qa) * m * par.n * pow(par.alfa, par.n)*pow(-h, par.n-1)*C1;
    }
    else
        return 0.0;
}
/*

          ! ************************************************************************
! FH - inverse water saturation function
! **************************************
real pure function FH_4(h,Matr)
implicit none
integer,INTENT(IN) :: Matr
real, INTENT(IN) :: h
  FH_4=FH_8(DBLE(h),Matr)
end function FH_4

double precision pure function FH_8(Qe,Matr)
implicit none
integer, INTENT(IN) :: Matr
double precision,INTENT(IN) :: Qe
double precision :: n,m,Qr,Qs,Qa,Qm,Alfa,Q,Qee

  Qr=par(1,Matr)
  Qs=par(2,Matr)
  Qa=par(3,Matr)
  Qm=par(4,Matr)
  Alfa=par(5,Matr)
  n=par(6,Matr)
  m=1-1/n
  Q=Qr+(Qs-Qr)*Qe
  Qee=dmax1((Q-Qa)/(Qm-Qa),1d-3)
  Qee=dmin1(Qee,1-1d-15)
  FH_8=-1/Alfa*(Qee**(-1/m)-1)**(1/n)
end function FH_8
*/

// Conductivity for analytical solution
/*
class HydroModel_analytical
{
public:
    HydroModel_analytical(ParameterHandler &prm) {};

    /// Maximum point of capacity. (computed numericaly from eq. atan(x)*2x=1 )
    inline double cap_arg_max() const { return -0.765378926665788882857; }

    template <class T>
    T FK(const T &h) const
    {
        if (h>=0.0) return ( 2.0 );
        return ( 2.0 / (1+h*h) );
    }

    template <class T>
    T FQ(const T &h) const
    {
        static T pi_half =std::atan(1.0)*2;
        if (h>=0.0) return ( 2.0*pi_half*pi_half );
        T a_tan = atan(h);
        return ( 2*pi_half*pi_half - a_tan*a_tan );
    }
private:
    double arg_cap_max;
};


class HydroModel_linear
{
    HydroModel_linear(ParameterHandler &prm) {};

public:
    template <class T>
    T FK(const T &h) const {
        return 1.0;
    }

    template <class T>
    T FQ(const T &h) const {
        return h;
    }
};

*/
#endif	/* _HYDRO_FUNCTIONS_HH */
